
import Foundation

class BankClerk {
    let counterNumber: Int
    var totalWorkingTime: Float = 0
    var totalProcessedClients: Int = 0
    var workingStatus: BankClerkStatus {
        didSet {
            if workingStatus == .workable {
                NotificationCenter.default.post(name: Notification.Name("workable"), object: nil, userInfo: ["counterNumber": self.counterNumber])
            }
        }
    }
    
    init(counterNumber: Int) {
        self.counterNumber = counterNumber
        self.workingStatus = .off
    }
    
    func handleClientBusiness(of client: Client) {
        self.workingStatus = .working
        print("\(client.waitingNumber)번 \(client.grade.rawValue)고객 \(client.business.rawValue)업무 시작")
        
        switch client.business {
        case .deposit:
            Thread.sleep(forTimeInterval: 0.7)
            totalWorkingTime += 0.7
        case .loan:
            Thread.sleep(forTimeInterval: 1.1)
            totalWorkingTime += 1.1
        }
        
        totalProcessedClients += 1
        
        print("\(client.waitingNumber)번 \(client.grade.rawValue)고객 \(client.business.rawValue)업무 종료")
        self.workingStatus = .workable
    }
}

