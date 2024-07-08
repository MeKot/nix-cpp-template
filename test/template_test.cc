#include <nix_cpp_template/template_header.hh>

#include "gtest/gtest.h"
#include "gmock/gmock.h"

TEST(SimpleTest, OnePlusOneEqualsTwo) {
  EXPECT_EQ(2, simple::Add(1, 1));
}
