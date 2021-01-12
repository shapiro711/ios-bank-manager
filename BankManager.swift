import Foundation

class Banker {
    private var windowNumber: UInt
    var isWorking: BankCondition {
        willSet {
            if newValue == .notWorking {
                workDone()
            }
        }
    }
    var customer: Customer?
    var workTime: Double
    
    init(windowNumber: UInt, isWorking: BankCondition) {
        self.windowNumber = windowNumber
        self.isWorking = isWorking
        workTime = 0.0
    }
    
    func work() {
        guard let customer = customer else {
            print("고객이 없습니다!")
            return
        }
        print("\(customer.waiting)번 \(customer.priority.describing)고객 \(customer.businessType.rawValue) 업무 시작")
        flipCondition()
    }
    
    func flipCondition() {
        switch isWorking {
        case .working:
            isWorking = .notWorking
        case .notWorking:
            isWorking = .working
        }
    }
    
    private func workDone() {
        if let customer = customer {
            workTime += customer.taskTime
            print("\(customer.waiting)번 \(customer.priority.describing)고객 \(customer.businessType.rawValue) 업무 종료")
        }
    }
}

struct Customer {
    enum Priority: Int, CaseIterable {
        case vvip = 0
        case vip = 1
        case normal = 2
        
        var describing: String {
            switch self {
            case .vvip:
                return "VVIP"
            case .vip:
                return "VIP"
            case .normal:
                return "일반"
            }
        }
    }
    var waiting: UInt
    var taskTime: Double
    var businessType: BusinessType
    var priority: Customer.Priority
}

class Bank {
    private var bankers = [Banker]()
    private var businessTimes: Double = 0.0
    private var totalVisitedCustomers: UInt = 0
    private var dispatchQueue = DispatchQueue.global()
    private var semaphore = DispatchSemaphore(value: 0)
    private let dispatchGroup = DispatchGroup()
    
    func configureBankers(numberOfBankers: UInt) {
        for window in 0..<numberOfBankers {
            bankers.append(Banker(windowNumber: window, isWorking: .notWorking))
        }
    }
    
    func openBank() {
        while !customers.isEmpty {
            for windowNumber in 0..<bankers.count {
                checkBankerIsWorking(windowNumber)
            }
        }
        checkEnd()
        semaphore.wait()
        closeBank()
        initializeInfo()
    }
    
    private func checkBankerIsWorking(_ windowNumber: Int) {
        let banker = bankers[windowNumber]
        switch banker.isWorking {
        case .notWorking:
            startCustomerTask(in: windowNumber)
        case .working:
            return
        }
    }
    
    private func startCustomerTask(in windowNumber: Int) {
        let banker = bankers[windowNumber]
        if let customer = customers.first {
            banker.flipCondition()
            dispatchGroup.enter()
            dispatchQueue.asyncAfter(deadline: .now() + customer.taskTime, execute: {
                banker.customer = customer
                banker.work()
                self.dispatchGroup.leave()
            })
            totalVisitedCustomers += 1
            customers.removeFirst()
        }
    }
    
    private func checkEnd() {
        dispatchGroup.notify(queue: dispatchQueue, execute: {
            self.countOfTotalTime()
        })
    }

    private func countOfTotalTime() {
        bankers.sort { $0.workTime > $1.workTime }
        businessTimes = bankers[0].workTime
        semaphore.signal()
    }
    
    private func closeBank() {
        let businessTimeToString: String = String(format: "%.2f", businessTimes)
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(totalVisitedCustomers)명이며, 총 업무시간은 \(businessTimeToString)초 입니다.")
    }
    
    private func initializeInfo() {
        bankers = [Banker]()
        customers = [Customer]()
        businessTimes = 0.0
        totalVisitedCustomers = 0
    }
}
