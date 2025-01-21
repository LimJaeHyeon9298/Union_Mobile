//
//  VoteRequestTests.swift
//  VoteRequestTests
//
//  Created by 임재현 on 1/18/25.
//

import XCTest
@testable import UnionMobile_assignment


final class VoteRequestTests: XCTestCase {
    
    //MARK: - 정상 값 요청 들어왔을 경우
    func testVoteRequestVaildation_ValidInput_ShouldReturnTrue() {
        //Given
        let request = VoteRequest(userId: "userA", candidateId: 1)
        //When
        let isValid = request.isValid
        //Then
        XCTAssertTrue(isValid, "태스트 실패 - 유효성 검사 오류/ValidInput")
        print("테스트 통과: 유효한 입력값 검증 완료")
    }
    //MARK: - userId 최대 길이 (16자)
    func testVoteRequestVaildation_InvaildUserId_ShouldReturnFalse() {
        //Given
        let tooLongUserId = String(repeating: "a", count: 17)
        let request = VoteRequest(userId: tooLongUserId, candidateId: 1)
        //When
        let isValid = request.isValid
        //Then
        XCTAssertFalse(isValid, "테스트 실패 - 유효성 검사 오류/InvaildUserId")
        print("테스트 통과: ID 16글자 초과시 사용 불가 검증 완료")
        
    }
    //MARK: - candidateId 최소값 (1)
    func testVoteRequestVaildation_InvaildCandidateId_ShouldReturnFalse() {
        //Given
        let request = VoteRequest(userId: "userA", candidateId: 0)
        //When
        let isValid = request.isValid
        //Then
        XCTAssertFalse(isValid, "테스트 실패 - 유효성 검사 오류/InvaildCandidateId")
        print("테스트 통과: ID ")
        
    }
    //MARK: - 빈 문자열 경계 테스트
    func testVoteRequestVaildation_EmptyUserId_ShouldReturnFalse() {
        //Given
        let request = VoteRequest(userId: "", candidateId: 1)
        //When
        let isValid = request.isValid
        //Then
        XCTAssertFalse(isValid, "테스트 실패 - 빈 문자열 userId 허용됨")
        print("테스트 통과: 빈 문자열 userId 검증 완료")
    }
    //MARK: - 공백 문자열 포함 경계 테스트
    func testVoteRequestVaildation_WhitespaceUserId_ShouldReturnFalse() {
        //Given
        let request = VoteRequest(userId: "    ", candidateId: 1)
        //When
        let isValid = request.isValid
        // Then
        XCTAssertFalse(isValid, "테스트 실패 - 공백만 있는 userId 허용됨")
        print("테스트 통과: 공백 문자열 userId 검증 완료")
    }
    //MARK: - 특수 문자 포함 경계 테스트
    func testVoteRequestValidation_SpecialCharactersUserId_ShouldReturnFalse() {
        // Given
        let request = VoteRequest(userId: "user@#$%", candidateId: 1)
        // When
        let isValid = request.isValid
        // Then
        XCTAssertFalse(isValid, "테스트 실패 - 특수문자 포함된 userId 허용됨")
        print("테스트 통과: 특수문자 포함 userId 검증 완료")
    }
    //MARK: - 음수값 경계 테스트
    func testVoteRequestValidation_NegativeCandidateId_ShouldReturnFalse() {
        // Given
        let request = VoteRequest(userId: "userA", candidateId: -1)
        // When
        let isValid = request.isValid
        // Then
        XCTAssertFalse(isValid, "테스트 실패 - 음수 candidateId 허용됨")
        print("테스트 통과: 음수 candidateId 검증 완료")
    }
    //MARK: - candidateId 최대값
    func testVoteRequestValidation_MaxBoundaryCandidateId_ShouldReturnTrue() {
        // Given
        let request = VoteRequest(userId: "userA", candidateId: Int.max)
        // When
        let isValid = request.isValid
        // Then
        XCTAssertTrue(isValid, "테스트 실패 - 최대값 candidateId 거부됨")
        print("테스트 통과: 최대값 candidateId 검증 완료")
    }
    //MARK: - 정확히 16자 길이 경계값 테스트
    func testVoteRequestValidation_BoundaryUserId_16Characters_ShouldReturnTrue() {
        // Given
        let sixteenCharUserId = String(repeating: "a", count: 16)
        let request = VoteRequest(userId: sixteenCharUserId, candidateId: 1)
        // When
        let isValid = request.isValid
        // Then
        XCTAssertTrue(isValid, "테스트 실패 - 정확히 16자 userId 거부됨")
        print("테스트 통과: 16자 경계값 userId 검증 완료")
    }
}
