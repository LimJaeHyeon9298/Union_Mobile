//
//  VoteRepositoryTests.swift
//  VoteRepositoryTests
//
//  Created by 임재현 on 1/18/25.
//

import XCTest
@testable import UnionMobile_assignment

final class VoteRepositoryTests: XCTestCase {
    
    var repository: VoteRepositoryImplements!
    var mockNetworkService: NetworkService!
    
    override func setUp() {
        mockNetworkService = NetworkService()
        repository = VoteRepositoryImplements(networkService: mockNetworkService)
    }
    
    func testSubmitVote_ValidRequest_ShouldSucceed() async {
        let request = VoteRequest(userId: "HoHo", candidateId: 48)
        
        do {
            try await repository.submitVote(request)
            XCTAssertTrue(true, "투표 제출 성공")
            print("제출 완료")
        } catch {
            XCTFail("예상치 못한 에러 발생: \(error)")
        }
    }
    
    func testGetCandidateAPI() async throws {
        do {
            let candidate = try await repository.getCandidate(id: 48, userId: "HaHa")
            // Then
            print("=== 후보자 정보 요청 성공 ===")
            print("후보자 ID: \(candidate.id)")
            print("이름: \(candidate.name)")
            print("국가: \(candidate.country)")
            print("전공: \(candidate.profile.major)")
            print("교육: \(candidate.profile.education)")
            print("이미지 URL 갯수: \(candidate.profile.images.count)")
            if let firstImageUrl = candidate.profile.images.first?.url {
                print("첫번째 이미지 URL: \(firstImageUrl)")
            }
            print("투표 여부: \(candidate.isVoted)")
            print("=========================")
            
            XCTAssertGreaterThan(candidate.id, 0)
            XCTAssertFalse(candidate.name.isEmpty)
            
        } catch {
            XCTFail("API 호출 실패: \(error)")
            print("에러 발생: \(error)")
        }
    }
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
