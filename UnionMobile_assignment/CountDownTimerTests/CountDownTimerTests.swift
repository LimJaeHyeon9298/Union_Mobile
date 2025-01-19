//
//  CountDownTimerTests.swift
//  CountDownTimerTests
//
//  Created by 임재현 on 1/19/25.
//

import XCTest
@testable import UnionMobile_assignment
import SwiftUI
import Combine

//MARK: - 타이머 테스트
final class CountDownTimerTests: XCTestCase {
    var timer: CountdownTimer!
    var cancellables: Set<AnyCancellable>!
    override func setUp() {
            super.setUp()
            cancellables = []
        }
        
        override func tearDown() {
            timer = nil
            cancellables = nil
            super.tearDown()
        }
        
        // MARK: - 메모리 해제 테스트
        func testTimerDeinitialization() {
            weak var weakTimer: CountdownTimer?
            
            autoreleasepool {
                let timer = CountdownTimer(targetDate: Date().addingTimeInterval(3600))
                timer.start()
                weakTimer = timer
            }
            
            XCTAssertNil(weakTimer, "Timer should be deallocated")
        }
        
        // MARK: - 타이머 시작/정지 테스트
        func testTimerStartStop() {
            let expectation = XCTestExpectation(description: "Timer updates")
            var updateCount = 0
            
            let targetDate = Date().addingTimeInterval(3600) // 1시간 후
            timer = CountdownTimer(targetDate: targetDate)
            
            timer.$timeRemaining
                .dropFirst() // 초기값 무시
                .sink { _ in
                    updateCount += 1
                }
                .store(in: &cancellables)
            
            timer.start()
            
            // 3초 동안 타이머 실행
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.timer.stop()
                XCTAssertGreaterThan(updateCount, 0, "Timer should have updated at least once")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 4)
        }
        
        // MARK: - 백그라운드 전환 시뮬레이션 테스트
        func testTimerBackgroundBehavior() {
            let targetDate = Date().addingTimeInterval(3600)
            timer = CountdownTimer(targetDate: targetDate)
            
            // 타이머 시작
            timer.start()
            let initialRemaining = timer.timeRemaining
            
            // 백그라운드로 전환
            timer.stop()
            
            // 5초 지연 시뮬레이션
            Thread.sleep(forTimeInterval: 5)
            
            // 다시 포그라운드로 전환
            timer.updateTimeRemaining()
            timer.start()
            
            // 실제 경과 시간이 반영되었는지 확인
            XCTAssertEqual(
                round(timer.timeRemaining),
                round(initialRemaining - 5),
                accuracy: 1.0,
                "Timer should reflect actual elapsed time"
            )
        }
        
        // MARK: - 타이머 정확도 테스트
    func testTimerAccuracy() {
        let expectation = XCTestExpectation(description: "Timer accuracy")
        let targetDate = Date().addingTimeInterval(3) // 3초로 늘림
        timer = CountdownTimer(targetDate: targetDate)
        
        var lastUpdate: TimeInterval?
        var updateIntervals: [TimeInterval] = []
        
        timer.$timeRemaining
            .dropFirst() // 초기값 무시
            .sink { timeRemaining in
                if let last = lastUpdate {
                    let interval = last - timeRemaining
                    updateIntervals.append(interval)
                }
                lastUpdate = timeRemaining
                
                if timeRemaining <= 0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        timer.start()
        
        wait(for: [expectation], timeout: 4)
        
        // 최소 2개의 간격이 있는지 확인
        XCTAssertGreaterThanOrEqual(updateIntervals.count, 2,
                                   "Should have at least 2 intervals")
        
        // 각 업데이트 간격이 대략 1초인지 확인
        for interval in updateIntervals {
            XCTAssertEqual(interval, 1.0, accuracy: 0.3,
                          "Update interval should be approximately 1 second")
        }
    }
        
    
       // MARK: - View의 타이머 객체 메모리 관리 테스트
       func testViewTimerObjectManagement() {
           weak var weakTimer: CountdownTimer?
           
           autoreleasepool {
               let targetDate = Date().addingTimeInterval(3600)
               let timerView = CountdownTimerView(targetDate: targetDate)
               
               // View를 호스팅하고 타이머 객체 참조 획득
               let hostingController = UIHostingController(rootView: timerView)
               _ = hostingController.view
               
               // StateObject로 생성된 타이머에 대한 참조 획득
               let mirror = Mirror(reflecting: timerView)
               for child in mirror.children {
                   if let timer = child.value as? CountdownTimer {
                       weakTimer = timer
                       break
                   }
               }
               
               // 라이프사이클 시뮬레이션
               NotificationCenter.default.post(
                   name: UIScene.didActivateNotification,
                   object: nil
               )
               
               NotificationCenter.default.post(
                   name: UIScene.didEnterBackgroundNotification,
                   object: nil
               )
           }
           
           // 타이머 객체가 제대로 해제되었는지 확인
           XCTAssertNil(weakTimer, "Timer object should be deallocated")
       }
       
       // MARK: - 호스팅 컨트롤러 메모리 관리 테스트
       func testHostingControllerManagement() {
           weak var weakHostingController: UIHostingController<CountdownTimerView>?
           
           autoreleasepool {
               let targetDate = Date().addingTimeInterval(3600)
               let timerView = CountdownTimerView(targetDate: targetDate)
               let hostingController = UIHostingController(rootView: timerView)
               weakHostingController = hostingController
               
               // 뷰 로드 시뮬레이션
               _ = hostingController.view
           }
           
           // 호스팅 컨트롤러가 제대로 해제되었는지 확인
           XCTAssertNil(weakHostingController, "HostingController should be deallocated")
       }
    
}

//MARK: - 타이머 성능 테스트
class CountdownTimerPerformanceTests: XCTestCase {
    func testTimerPerformance() {
        measure {
            let targetDate = Date().addingTimeInterval(3600)
            let timer = CountdownTimer(targetDate: targetDate)
            timer.start()
            
            // 짧은 실행 시간 동안의 성능 측정
            Thread.sleep(forTimeInterval: 0.1)
            timer.stop()
        }
    }
    //MARK: - 메모리 사용량 테스트
    func testMemoryUsage() {
        var memoryBefore: Int = 0
        var memoryAfter: Int = 0
        
        autoreleasepool {
            memoryBefore = getMemoryUsage()
            
            // 100개의 타이머 생성 및 시작
            for _ in 0..<100 {
                autoreleasepool {
                    let targetDate = Date().addingTimeInterval(3600)
                    let timer = CountdownTimer(targetDate: targetDate)
                    timer.start()
                    Thread.sleep(forTimeInterval: 0.01)
                    timer.stop()
                }
            }
            
            memoryAfter = getMemoryUsage()
        }
        
        // 메모리 사용량이 크게 증가하지 않았는지 확인
        XCTAssertLessThan(
            memoryAfter - memoryBefore,
            5 * 1024 * 1024, // 5MB 이하의 증가만 허용
            "Memory usage increased significantly"
        )
    }
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            return 0
        }
        
        return Int(info.resident_size)
    }
}
