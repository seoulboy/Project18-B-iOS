//
//  AppCoordinator.swift
//  BoostRunClub
//
//  Created by Imho Jang on 2020/11/23.
//

import Combine
import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func showLoginFlow()
    func showMainFlow()
}

final class AppCoordinator: AppCoordinatorProtocol {
    var navigationController: UINavigationController

    var childCoordinators = [Coordinator]()

    var cancellable: AnyCancellable?

    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: true)

        cancellable = NotificationCenter.default
            .publisher(for: .showRunningScene)
            .sink { [weak self] notification in
                guard
                    let self = self,
                    let goalType = notification.userInfo?["goalType"] as? GoalType
                else { return }

                self.clear()
                self.showRunningScene(goalType)
            }
    }

    func start() {
        showMainFlow()
    }

    func showLoginFlow() {
        let loginCoordinator = LoginCoordinator(navigationController)
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }

    func showMainFlow() {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController)
        childCoordinators.append(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
    }

    func showRunningScene(_: GoalType) {
        let runningVC = RunningViewController()
        navigationController.pushViewController(runningVC, animated: false)
    }
}
