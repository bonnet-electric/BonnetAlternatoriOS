//
//  LogsViewModel.swift
//  Bonnet
//
//  Created by Ana Marquez on 31/01/2024.
//

import Foundation
import Combine

class LogsViewModel: ObservableObject {
//    @Published var logs: [LogService.Log] = []
    
    internal var cancellables: Set<AnyCancellable> = []
    
    public let logsService: LogService
    
    init(logsService: LogService = .shared) {
        self.logsService = logsService
    }
    
//    deinit {
//        cancellables.removeAll()
//    }
//    
//    override func addListeners() {
//        self.logsService.logs.$value.receive(on: DispatchQueue.main).sink { value in
//            self.logs = value
//        }.store(in: &cancellables)
//    }
}
