//
//  SkillzProgressionService.swift
//  BubbleShooter
//

import Foundation

enum SkillzProgressionError: LocalizedError {
    case notEnoughCoins
    case alreadyOwned
    case remote(String)

    var errorDescription: String? {
        switch self {
        case .notEnoughCoins:
            "Not enough coins for this purchase."
        case .alreadyOwned:
            "You already own this item."
        case .remote(let message):
            message
        }
    }
}

/// Syncs shop state via Skillz Progression API (device) or UserDefaults (simulator / fallback).
final class SkillzProgressionService {

    static let shared = SkillzProgressionService()

    private(set) var state: PlayerProgressionState = .initial

    private let defaults = UserDefaults.standard
    private let defaultsPrefix = "progression.mock."

    private init() {
        state = loadMockState()
    }

    // MARK: - Public

    func refresh(completion: @escaping (Result<PlayerProgressionState, Error>) -> Void) {
        #if USE_SKILLZ_SDK
        fetchFromSkillz { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let remote):
                self.state = remote
                self.saveMockState(remote)
                completion(.success(remote))
            case .failure:
                let local = self.loadMockState()
                self.state = local
                completion(.success(local))
            }
        }
        #else
        state = loadMockState()
        completion(.success(state))
        #endif
    }

    func purchase(
        _ item: CosmeticShopItem,
        completion: @escaping (Result<PlayerProgressionState, Error>) -> Void
    ) {
        guard !state.isOwned(item) else {
            completion(.failure(SkillzProgressionError.alreadyOwned))
            return
        }
        guard state.softCurrency >= item.price else {
            completion(.failure(SkillzProgressionError.notEnoughCoins))
            return
        }

        var next = state
        next.applyPurchase(item)

        #if USE_SKILLZ_SDK
        pushToSkillz(updates: next.progressionUpdates(for: item)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.state = next
                self.saveMockState(next)
                completion(.success(next))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        #else
        state = next
        saveMockState(next)
        completion(.success(next))
        #endif
    }

    func grantMatchReward(completion: @escaping (Result<PlayerProgressionState, Error>) -> Void) {
        var next = state
        next.grantMatchReward()

        #if USE_SKILLZ_SDK
        pushToSkillz(updates: next.matchRewardUpdates()) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.state = next
                self.saveMockState(next)
                completion(.success(next))
            case .failure:
                self.state = next
                self.saveMockState(next)
                completion(.success(next))
            }
        }
        #else
        state = next
        saveMockState(next)
        completion(.success(next))
        #endif
    }

    // MARK: - Skillz

    #if USE_SKILLZ_SDK
    private func fetchFromSkillz(completion: @escaping (Result<PlayerProgressionState, Error>) -> Void) {
        let keys = NSMutableArray(array: ProgressionKeys.allShopKeys)
        Skillz.skillzInstance().getUserData(
            forNamespace: ProgressionKeys.namespacePlayerData,
            withKeys: keys,
            withSuccess: { userData in
                guard let userData else {
                    completion(.success(PlayerProgressionState.initial))
                    return
                }
                completion(.success(PlayerProgressionState.fromProgressionDictionary(userData)))
            },
            withFailure: { error in
                completion(.failure(SkillzProgressionError.remote(error ?? "Progression fetch failed")))
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
                completion(.failure(SkillzProgressionError.remote(error ?? "Progression update failed")))
            }
        )
    }
    #endif

    // MARK: - Mock persistence

    private func loadMockState() -> PlayerProgressionState {
        PlayerProgressionState(
            softCurrency: defaults.object(forKey: defaultsPrefix + ProgressionKeys.softCurrency) as? Int
                ?? PlayerProgressionState.startingCoins,
            ownedBubbleRibbon: defaults.bool(forKey: defaultsPrefix + ProgressionKeys.ownedBubbleRibbon),
            ownedBubbleShimmer: defaults.bool(forKey: defaultsPrefix + ProgressionKeys.ownedBubbleShimmer),
            ownedBubblePlanet: defaults.bool(forKey: defaultsPrefix + ProgressionKeys.ownedBubblePlanet),
            ownedBubbleGlossy: defaults.bool(forKey: defaultsPrefix + ProgressionKeys.ownedBubbleGlossy),
            ownedCannonGold: defaults.bool(forKey: defaultsPrefix + ProgressionKeys.ownedCannonGold)
        )
    }

    private func saveMockState(_ state: PlayerProgressionState) {
        defaults.set(state.softCurrency, forKey: defaultsPrefix + ProgressionKeys.softCurrency)
        defaults.set(state.ownedBubbleRibbon, forKey: defaultsPrefix + ProgressionKeys.ownedBubbleRibbon)
        defaults.set(state.ownedBubbleShimmer, forKey: defaultsPrefix + ProgressionKeys.ownedBubbleShimmer)
        defaults.set(state.ownedBubblePlanet, forKey: defaultsPrefix + ProgressionKeys.ownedBubblePlanet)
        defaults.set(state.ownedBubbleGlossy, forKey: defaultsPrefix + ProgressionKeys.ownedBubbleGlossy)
        defaults.set(state.ownedCannonGold, forKey: defaultsPrefix + ProgressionKeys.ownedCannonGold)
    }
}
