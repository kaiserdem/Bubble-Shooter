//
//  AchievementService.swift
//  BubbleShooter
//

import Foundation

/// Tracks achievement progress and grants rewards through `SkillzProgressionService`.
final class AchievementService {

    static let shared = AchievementService()

    private(set) var progress: AchievementProgressState = .initial

    private let defaults = UserDefaults.standard
    private let defaultsPrefix = "achievement.local."

    private init() {
        progress = loadLocalState()
    }

    // MARK: - Public

    func refresh(completion: @escaping () -> Void) {
        let local = loadLocalState()
        progress = local

        #if USE_SKILLZ_SDK
        fetchFromSkillz { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let remote):
                let merged = local.merged(withRemote: remote)
                self.progress = merged
                self.saveLocalState(merged)
            case .failure:
                self.progress = local
            }
            completion()
        }
        #else
        completion()
        #endif
    }

    func recordMatch(
        results: MatchResultsState,
        completion: @escaping ([AchievementID]) -> Void
    ) {
        var next = progress
        next.matchesPlayed += 1
        next.bubblesPopped += results.poppedBubbleCount
        if results.didClearBoard {
            next.boardClears += 1
        }
        next.bestScore = max(next.bestScore, results.finalScore)
        next.bestDropsInMatch = max(next.bestDropsInMatch, results.droppedBubbleCount)

        applyProgressUpdate(next) { newlyClaimed in
            completion(newlyClaimed)
        }
    }

    func recordCosmeticPurchase(completion: @escaping ([AchievementID]) -> Void) {
        var next = progress
        next.cosmeticsPurchased += 1

        applyProgressUpdate(next) { newlyClaimed in
            completion(newlyClaimed)
        }
    }

    func reevaluate(completion: @escaping ([AchievementID]) -> Void) {
        applyProgressUpdate(progress, completion: completion)
    }

    // MARK: - Private

    private func applyProgressUpdate(
        _ next: AchievementProgressState,
        completion: @escaping ([AchievementID]) -> Void
    ) {
        let progression = SkillzProgressionService.shared.state
        let toClaim = AchievementDefinition.all.compactMap { definition -> AchievementID? in
            guard !next.isClaimed(definition.id) else { return nil }
            guard definition.isComplete(progress: next, progression: progression) else { return nil }
            return definition.id
        }

        guard toClaim.isEmpty else {
            claimSequentially(ids: toClaim, progress: next, index: 0, claimed: []) { [weak self] allClaimed in
                self?.reevaluate { moreClaimed in
                    completion(allClaimed + moreClaimed)
                }
            }
            return
        }

        persistProgress(next) {
            completion([])
        }
    }

    private func claimSequentially(
        ids: [AchievementID],
        progress: AchievementProgressState,
        index: Int,
        claimed: [AchievementID],
        completion: @escaping ([AchievementID]) -> Void
    ) {
        guard index < ids.count else {
            completion(claimed)
            return
        }

        let id = ids[index]
        let definition = AchievementDefinition.definition(for: id)
        var updatedProgress = progress
        updatedProgress.markClaimed(id)

        let coins: Int
        let cosmetic: CosmeticShopItem?
        switch definition.reward {
        case .coins(let amount):
            coins = amount
            cosmetic = nil
        case .cosmetic(let item):
            coins = 0
            cosmetic = item
        }

        SkillzProgressionService.shared.grantAchievementReward(
            coins: coins,
            cosmetic: cosmetic
        ) { [weak self] _ in
            self?.persistProgress(updatedProgress) {
                var nextClaimed = claimed
                nextClaimed.append(id)
                self?.claimSequentially(
                    ids: ids,
                    progress: updatedProgress,
                    index: index + 1,
                    claimed: nextClaimed,
                    completion: completion
                )
            }
        }
    }

    private func persistProgress(
        _ state: AchievementProgressState,
        completion: @escaping () -> Void
    ) {
        progress = state
        saveLocalState(state)

        #if USE_SKILLZ_SDK
        pushToSkillz(updates: state.progressionDictionary()) { [weak self] result in
            if case .failure = result {
                self?.saveLocalState(state)
            }
            completion()
        }
        #else
        completion()
        #endif
    }

    #if USE_SKILLZ_SDK
    private func fetchFromSkillz(
        completion: @escaping (Result<AchievementProgressState, Error>) -> Void
    ) {
        let keys = NSMutableArray(array: AchievementKeys.allKeys)
        Skillz.skillzInstance().getUserData(
            forNamespace: ProgressionKeys.namespacePlayerData,
            withKeys: keys,
            withSuccess: { userData in
                guard let userData else {
                    completion(.failure(SkillzProgressionError.remote("No achievement data")))
                    return
                }
                completion(.success(AchievementProgressState.fromProgressionDictionary(userData)))
            },
            withFailure: { error in
                completion(.failure(SkillzProgressionError.remote(error ?? "Achievement fetch failed")))
            }
        )
    }

    private func pushToSkillz(
        updates: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Skillz.skillzInstance().updateUserData(
            forNamespace: ProgressionKeys.namespacePlayerData,
            withUserData: updates,
            withSuccess: { _ in
                completion(.success(()))
            },
            withFailure: { error in
                completion(.failure(SkillzProgressionError.remote(error ?? "Achievement update failed")))
            }
        )
    }
    #endif

    private func loadLocalState() -> AchievementProgressState {
        var claimed = Set<AchievementID>()
        for id in AchievementID.allCases {
            if defaults.bool(forKey: defaultsPrefix + AchievementKeys.claimedKey(for: id)) {
                claimed.insert(id)
            }
        }

        return AchievementProgressState(
            matchesPlayed: defaults.integer(forKey: defaultsPrefix + AchievementKeys.statMatchesPlayed),
            bubblesPopped: defaults.integer(forKey: defaultsPrefix + AchievementKeys.statBubblesPopped),
            boardClears: defaults.integer(forKey: defaultsPrefix + AchievementKeys.statBoardClears),
            bestScore: defaults.integer(forKey: defaultsPrefix + AchievementKeys.statBestScore),
            bestDropsInMatch: defaults.integer(forKey: defaultsPrefix + AchievementKeys.statBestDropsInMatch),
            cosmeticsPurchased: defaults.integer(
                forKey: defaultsPrefix + AchievementKeys.statCosmeticsPurchased
            ),
            claimed: claimed
        )
    }

    private func saveLocalState(_ state: AchievementProgressState) {
        defaults.set(state.matchesPlayed, forKey: defaultsPrefix + AchievementKeys.statMatchesPlayed)
        defaults.set(state.bubblesPopped, forKey: defaultsPrefix + AchievementKeys.statBubblesPopped)
        defaults.set(state.boardClears, forKey: defaultsPrefix + AchievementKeys.statBoardClears)
        defaults.set(state.bestScore, forKey: defaultsPrefix + AchievementKeys.statBestScore)
        defaults.set(state.bestDropsInMatch, forKey: defaultsPrefix + AchievementKeys.statBestDropsInMatch)
        defaults.set(
            state.cosmeticsPurchased,
            forKey: defaultsPrefix + AchievementKeys.statCosmeticsPurchased
        )
        for id in AchievementID.allCases {
            defaults.set(
                state.claimed.contains(id),
                forKey: defaultsPrefix + AchievementKeys.claimedKey(for: id)
            )
        }
    }
}
