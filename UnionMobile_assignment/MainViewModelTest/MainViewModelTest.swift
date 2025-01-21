//
//  MainViewModelTest.swift
//  MainViewModelTest
//
//  Created by 임재현 on 1/21/25.
//

import XCTest
@testable import UnionMobile_assignment

 class MainViewModelTest: XCTestCase {
    var container: DIContainer!
    var viewModel: MainViewModel!
    var mockNetworkService: MockNetworkService!
        
        override func setUp() {
            super.setUp()
            mockNetworkService = MockNetworkService()
            container = DIContainer(testNetworkService: mockNetworkService)
            viewModel = container.makeMainViewModel()
        }
     
         override func tearDown() {
             viewModel = nil
             container = nil
             mockNetworkService = nil
             super.tearDown()
         }
     
     // MARK: - 캐시 유효성 테스트
         func testCacheValidityPeriod() async throws {
             // Given
             let mockResponse = CandidateListResponseDTO(
                 content: [
                     CandidateListItemDTO(
                         id: 1,
                         candidateNumber: 1,
                         name: "Test Candidate",
                         profileUrl: "https://example.com/profile.jpg",
                         voteCnt: "100"
                     )
                 ],
                 pageable: PageableDTO(
                     sort: SortDTO(empty: false, sorted: true, unsorted: false),
                     offset: 0,
                     pageNumber: 0,
                     pageSize: 10,
                     paged: true,
                     unpaged: false
                 ),
                 totalPages: 1,
                 totalElements: 1,
                 last: true,
                 size: 10,
                 number: 0,
                 sort: SortDTO(empty: false, sorted: true, unsorted: false),
                 numberOfElements: 1,
                 first: true,
                 empty: false
             )
             mockNetworkService.mockResponse = mockResponse
             
             // When - 첫 번째 호출
             await viewModel.fetchCandidates(userId: "testUser")
             let firstCallCount = mockNetworkService.requestCount
             
             // 캐시 유효 기간 내 두 번째 호출
             await viewModel.fetchCandidates(userId: "testUser")
             
             // Then
             XCTAssertEqual(mockNetworkService.requestCount, firstCallCount)
             
             // When - 캐시 만료 후 호출
             try await Task.sleep(nanoseconds: UInt64(31 * 1_000_000_000))
             await viewModel.fetchCandidates(userId: "testUser")
             
             // Then
             XCTAssertGreaterThan(mockNetworkService.requestCount, firstCallCount)
         }
     
     // MARK: - 강제 새로고침 테스트
        func testForceRefresh() async throws {
            // Given
            let mockResponse = CandidateListResponseDTO(
                content: [
                    CandidateListItemDTO(
                        id: 1,
                        candidateNumber: 101,
                        name: "Test Candidate",
                        profileUrl: "https://example.com/1.jpg",
                        voteCnt: "100"
                    )
                ],
                pageable: PageableDTO(
                    sort: SortDTO(empty: false, sorted: true, unsorted: false),
                    offset: 0,
                    pageNumber: 0,
                    pageSize: 10,
                    paged: true,
                    unpaged: false
                ),
                totalPages: 1,
                totalElements: 1,
                last: true,
                size: 10,
                number: 0,
                sort: SortDTO(empty: false, sorted: true, unsorted: false),
                numberOfElements: 1,
                first: true,
                empty: false
            )
            mockNetworkService.mockResponse = mockResponse
            
            // When - 일반 호출
            await viewModel.fetchCandidates(userId: "testUser")
            let initialCallCount = mockNetworkService.requestCount
            
            // When - 강제 새로고침
            await viewModel.fetchCandidates(forceRefresh: true, userId: "testUser")
            
            // Then
            XCTAssertGreaterThan(mockNetworkService.requestCount, initialCallCount, "강제 새로고침 시 새로운 네트워크 요청이 발생해야 함")
        }
        
        // MARK: - 네트워크 에러 처리 테스트
        func testNetworkErrorHandling() async throws {
            // Given
            mockNetworkService.shouldFail = true
            mockNetworkService.mockError = NetworkError.serverError(statusCode: 500)
            
            // When
            await viewModel.fetchCandidates(userId: "testUser")
            
            // Then
            XCTAssertNotNil(viewModel.error, "에러가 설정되어야 함")
            XCTAssertTrue(viewModel.candidates.isEmpty, "에러 발생 시 후보자 목록이 비어있어야 함")
            XCTAssertFalse(viewModel.isLoading, "에러 발생 후 로딩 상태가 해제되어야 함")
            
            if case .serverError(let statusCode) = viewModel.error as? NetworkError {
                XCTAssertEqual(statusCode, 500, "서버 에러 상태 코드가 일치해야 함")
            } else {
                XCTFail("Expected server error")
            }
        }
        
        // MARK: - 최대 투표 수 제한 테스트
        func testMaxVotesRestriction() async throws {
            // Given
            let voteRequest = VoteRequest(userId: "testUser", candidateId: 1)
            let errorResponse = APIErrorResponse(errorCode: "2005", errorMessage: "Maximum votes reached")
            mockNetworkService.shouldFail = true
            mockNetworkService.mockError = NetworkError.badRequest(errorResponse)
            
            // When & Then
            do {
                try await viewModel.submitVote(request: voteRequest)
                XCTFail("최대 투표 수 초과 시 에러가 발생해야 함")
            } catch {
                XCTAssertTrue(viewModel.showMaxVotesAlert, "최대 투표 수 초과 알림이 표시되어야 함")
                if case NetworkError.badRequest(let apiError) = error {
                    XCTAssertEqual(apiError.errorCode, "2005", "에러 코드가 일치해야 함")
                } else {
                    XCTFail("Expected bad request error with code 2005")
                }
            }
        }
}
