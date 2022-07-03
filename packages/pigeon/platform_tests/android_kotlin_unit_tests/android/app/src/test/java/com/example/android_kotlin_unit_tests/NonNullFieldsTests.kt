package com.example.android_kotlin_unit_tests

import junit.framework.TestCase
import org.junit.Test

class NonNullFieldsTests: TestCase() {
    @Test
    fun testMake() {
        val request = NonNullFieldSearchRequest("hello")
        assertEquals("hello", request.query)
    }
}