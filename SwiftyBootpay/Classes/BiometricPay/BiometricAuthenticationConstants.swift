//
//  BiometricAuthenticationConstants.swift
//  BiometricAuthentication
//
//  Created by Rushi on 27/10/17.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation
//import LocalAuthentication

let kBiometryNotAvailableReason = "Biometric authentication is not available for this device."

/// ****************  Touch ID  ****************** ///

let kTouchIdAuthenticationReason = "지문 센서를 터치해 주세요."
let kTouchIdAuthenticationReasonForNewCard = "카드 등록을 위해, 지문 센서를 터치해 주세요."
let kTouchIdAuthenticationReasonForDeleteCard = "등록된 카드를 삭제하시려면, 지문 센서를 터치해 주세요."
let kTouchIdPasscodeAuthenticationReason = "실패한 횟수가 너무 많아 이제 Touch ID가 잠겼습니다. Touch ID를 잠금 해제하려면 암호를 입력하세요."

/// Error Messages Touch ID
let kSetPasscodeToUseTouchID = "Touch ID를 사용하려면, 설정 → Touch ID 및 암호로 이동하여 '암호 켜기'를 진행해주세요."
let kNoFingerprintEnrolled = "기기에 등록된 지문이 없습니다. 설정 → Touch ID 및 암호로 이동하여 지문을 등록하세요."
let kDefaultTouchIDAuthenticationFailedReason = "Touch ID가 지문을 인식하지 못했습니다. 등록 된 지문으로 다시 시도하세요."

/// ****************  Face ID  ****************** ///

let kFaceIdAuthenticationReason = "인증을 위해 얼굴을 인식해주세요."
let kFaceIdPasscodeAuthenticationReason = "실패한 시도가 너무 많아 이제 Face ID가 잠겼습니다. Face ID를 잠금 해제하려면 비밀번호를 입력하세요."

/// Error Messages Face ID
let kSetPasscodeToUseFaceID = "Face ID를 사용하려면, 설정 → Face ID 및 암호로 이동하여 '암호 켜기'를 진행해주세요."
let kNoFaceIdentityEnrolled = "기기에 등록 된 얼굴이 없습니다. 설정 → Face ID 및 암호로 이동하여 얼굴을 등록하세요."
let kDefaultFaceIDAuthenticationFailedReason = "Face ID does not recognize your face. Please try again with your enrolled face."
