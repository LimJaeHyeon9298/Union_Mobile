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
    
    func testGetVotedCandidates() async throws {
        do {
            let votedIds = try await repository.getVotedCandidates(userId: "HaHa")
            print("=== 투표한 후보자 목록 ===")
            print("투표한 후보자 ID들: \(votedIds)")
            print("투표 수: \(votedIds.count)")
            print("=====================")
            XCTAssertNotNil(votedIds)
        } catch {
            XCTFail("API 호출 실패: \(error)")
            print("에러 발생: \(error)")
        }
    }
    
    func testGetCandidateList() async throws {
           // When
           do {
               let result = try await repository.getCandidateList(
                   page: 0,
                   size: 3,
                   sort: ["voteCnt,DESC", "name,ASC"],
                   searchKeyword: nil
               )
               
               // Then
               print("=== 후보자 목록 ===")
               print("총 페이지: \(result.totalPages)")
               print("총 항목 수: \(result.totalElements)")
               print("현재 페이지: \(result.currentPage)")
               print("\n후보자들:")
               result.items.forEach { item in
                   print("- \(item.name) (ID: \(item.id), 득표수: \(item.voteCount))")
               }
               print("================")
               
               XCTAssertFalse(result.items.isEmpty)
               XCTAssertGreaterThan(result.totalElements, 0)
           } catch {
               XCTFail("API 호출 실패: \(error)")
               print("에러 발생: \(error)")
           }
       }
}
