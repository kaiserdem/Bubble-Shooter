
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        PlayerSettings.installDefaults()
        #if USE_SKILLZ_SDK
        SkillzSDKBridge.initialize(
            gameID: SkillzConfiguration.gameID,
            environment: SkillzConfiguration.environment,
            delegate: SkillzAppCoordinator.shared
        )
        #endif
        return true
    }
}
