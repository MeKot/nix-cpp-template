#include <simple.hh>

#include "gtest/gtest.h"
#include "gmock/gmock.h"

TEST(SimpleTest, OnePlusOneEqualsTwo) {
  EXPECT_EQ(2, simple::Add(1, 1));
}
