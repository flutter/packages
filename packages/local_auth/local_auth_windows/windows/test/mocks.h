// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_LOCAL_AUTH_LOCAL_AUTH_WINDOWS_WINDOWS_TEST_MOCKS_H_
#define PACKAGES_LOCAL_AUTH_LOCAL_AUTH_WINDOWS_WINDOWS_TEST_MOCKS_H_

#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "../local_auth.h"

namespace local_auth_windows {
namespace test {

namespace {

using ::testing::_;

class MockUserConsentVerifier : public UserConsentVerifier {
 public:
  explicit MockUserConsentVerifier() {}
  virtual ~MockUserConsentVerifier() = default;

  MOCK_METHOD(winrt::Windows::Foundation::IAsyncOperation<
                  winrt::Windows::Security::Credentials::UI::
                      UserConsentVerificationResult>,
              RequestVerificationForWindowAsync, (std::wstring localizedReason),
              (override));
  MOCK_METHOD(winrt::Windows::Foundation::IAsyncOperation<
                  winrt::Windows::Security::Credentials::UI::
                      UserConsentVerifierAvailability>,
              CheckAvailabilityAsync, (), (override));

  // Disallow copy and move.
  MockUserConsentVerifier(const MockUserConsentVerifier&) = delete;
  MockUserConsentVerifier& operator=(const MockUserConsentVerifier&) = delete;
};

}  // namespace
}  // namespace test
}  // namespace local_auth_windows

#endif  // PACKAGES_LOCAL_AUTH_LOCAL_AUTH_WINDOWS_WINDOWS_TEST_MOCKS_H_
