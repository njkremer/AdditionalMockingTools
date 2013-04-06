AdditionalMockingTools
======================

This project is designed to cover some cases where other mocking libraries were/are missing functionality. The main part of functionality that was missing was the ability to mock/stub class methods which was not covered by OCMock, however as of 3/15/13 OCMock 2.1 now offers mocking class methods. This functionality is still in there and is still being used in some of my own projects.

The other part of this library is for mocking the block response from NSURLConnections's `sendAsynchronousRequest:queue:completionHandler:` method. Specifically stubbing out the the `completionHandler`'s `NSURLResponse*`, `NSData*`, `NSError*` objects.

## Contents:

1. [Installation](#installation)
1. [Stubbing Class Methods](#stubbing)
1. [Verifying Class Methods](#verifying)
1. [NSURLConnection Mocking](#nsurlconnection)
1. [Additional Notes](#additionalNotes)
1. [Future TODOs](#futureTODOs)
1. [License](#license)

***

<a name="installation"></a>
# Installation

1. The .a file and the headers are located in the repository. They are in the `Release-universal-libarry` folder.
1. Drag and drop the .a file and the headers folder into your xcode project.
1. Click on your project in the Project Navigator in XCode.
1. Select the target you want to add the library to.
1. Go to the "Build Phases" tab
1. Add the library under the "Link Binary With Libraries" section.
1. \#import "AdditionalMockingTools.h" in the file(s) you want to use the library.

If your app is having problems "seeing" the library at linking time, you can check the "Library Search Path" using the following steps:

1. Click on your project in the Project Navigator in XCode.
1. Select the target you added the library to.
1. Select the "Build Settings" tab.
1. Select the "All" sub-tab to show all the build settings.
1. User the search bar to search for "Library"
1. Edit the "Library Search Paths" entry under the "Search Paths" section header to where your library is located.

<a name="stubbing"></a>
# Stubbing Class Methods

### Basic Stubbing
Stubbing class methods is pretty straight forward. is starts with creating a mock representation of the class:

```objc
id mock = [AMTClassMock mock:[SomeClass class]];
```

From here you can call the `when:thenReturn:` method off of the mocked representation object:

```objc
[mock when:[mock someMethod] thenReturn:@"stubbed value"];
```

So now when `[SomeClass someMethod]` is called then the string "stubbed value" will be returned.

### Stubbing with Selectors
In addition to using the `when:thenReturn:` way of stubbing you can stub using a `@selector` as well:

```objc
[mock whenSelector:@selector(someMethod) thenReturn:@"stubbed value"];
```

### Stubbing a Void Method
If you want a void class method to not have any effect you can use the `doNothingFor` method:

```objc
[[mock doNothingFor] voidMethod];
```

### IMPORTANT
Since there is no "instance" involved with class method calls, **ALL** invocations to the stubbed method will return the stubbed data until `removeMocking` 
is called on the mock representation of the class:

```objc
[mock removeMocking];
```

When the object is dealloced, `removeMocking` is automatically called (for example if a mock is locally scoped and the end of a unit test occurs). 
However if you have your mock representation in the unit test class, it will continue to call the stubbed method rather than the actual one, **regardless** of being in different unit tests.

See the [Additional Notes](#additionalNotes) section for some more info.

<a name="verifying"></a>
# Verifying Class Methods

### Basic Verification

To verify a class method was called, you need to create a mock representation of the class the same way you do for stubbing:

```objc
id mock = [AMTClassMock mock:[SomeClass class]];
```

From there you setup your expections:

```objc
[mock expect:[mock someMethod]];
```

Then you do the part of your unit test where you're expecting `someMethod` to be called. When that part is done you use the `verify` method to verify that `someMethod` was called exactly one time:

```objc
[mock verify];
```

If the method was not called, or was called **more** than one time an exception will be thrown which will fail the test.

### Verification of Mulitiple Executions

If you need to verify that a method was called **more** than once, you can use the following method:

```objc
[mock expect:[mock someMethod] toBeExecutedNumberOfTimes:3]; // The method should be called exactly 3 times.
```

Once again, this will fail the test if the method isn't called **exactly** 3 times.

### Verification with Selectors

Verification with selectors work much the same way:

```objc
[mock expectSelector:@selector(someMethod)];
// Do test stuff
[mock verify];
```

The counter part of `expectSelector:toBeExecutedNumberOfTimes:` also does exist.

See the [Additional Notes](#additionalNotes) section for some more info.

<a name="nsurlconnection"></a>
# NSURLConnection Mocking

The `NSURLConnection` stubbing methods were added to easily stub a couple of commonly used methods. The `[NSURLConnection sendSynchronousRequest:returningResponse:error:]` 
method could be mocked with other mocking frameworks such as OCMock, however I felt the way used in this library is a bit more concise and easier to use.

The other method will mock the callback block for the `[NSURLConnection sendAsynchronousRequest:queue:completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)]` 
which does not seem to be able to mocked with other mocking frameworks that I've seen.

### Mocking NSURLConnection's Synchronous Method



### Mocking NSURLConnection's Asynchronous Callback Method


<a name="additionalNotes"></a>
# Additional Notes

1. Currently the library doesn't use "argument matching" to restrict a stubbed method being called or for use with verification. Meaning if you intend to verify a method like
```objc
[mock expect:[mock someMethod:@"stuff"]];
// do some stuff here
[mock verify];
```
It will just check to make sure that `someMethod` was called exactly once, **regardless** of the parameter passed in. So if `[SomeClass someMethod:@"blah"]` was called, 
it would still succeed verification.

1. Currently the library only supports stubbing and verifying methods that take up to **four** parameters.

1. While it's considered "bad form" to test/verify private methods direclty, the `whenSelector:thenReturn:`, `expectSelector:`, and `expectSelector:toBeExecutedNumberOfTimes:` *can* be used on private methods, the library will not forbid it.

<a name="futureTODOs"></a>
# Future TODOs

<a name="license"></a>
# License

This software is license under the MIT License:

The MIT License (MIT)
Copyright (c) 2012 Nicholas Kremer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.