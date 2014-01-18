//
//  SQRLShipItStateSpec.m
//  Squirrel
//
//  Created by Justin Spahr-Summers on 2013-10-09.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "SQRLDirectoryManager.h"
#import "SQRLShipItState.h"

SpecBegin(SQRLShipItState)

__block SQRLDirectoryManager *directoryManager;
__block SQRLShipItState *state;

beforeEach(^{
	directoryManager = SQRLDirectoryManager.currentApplicationManager;

	NSURL *updateURL = [self createTestApplicationUpdate];
	state = [[SQRLShipItState alloc] initWithTargetBundleURL:self.testApplicationURL updateBundleURL:updateURL bundleIdentifier:nil codeSignature:self.testApplicationSignature];
	expect(state).notTo.beNil();

	expect(state.targetBundleURL).to.equal(self.testApplicationURL);
	expect(state.updateBundleURL).to.equal(updateURL);
	expect(state.bundleIdentifier).to.beNil();
	expect(state.codeSignature).to.equal(self.testApplicationSignature);
});

afterEach(^{
	NSURL *stateURL = [[directoryManager shipItStateURL] firstOrDefault:nil success:NULL error:NULL];
	expect(stateURL).notTo.beNil();
	
	[NSFileManager.defaultManager removeItemAtURL:stateURL error:NULL];
});

it(@"should copy", ^{
	SQRLShipItState *stateCopy = [state copy];
	expect(stateCopy).to.equal(state);
	expect(stateCopy).notTo.beIdenticalTo(state);
});

it(@"should fail to read state when no file exists yet", ^{
	NSError *error = nil;
	BOOL success = [[SQRLShipItState readFromURL:directoryManager.shipItStateURL.first] waitUntilCompleted:&error];
	expect(success).to.beFalsy();
	expect(error).notTo.beNil();
});

it(@"should write and read state", ^{
	NSURL *URL = directoryManager.shipItStateURL.first;

	NSError *error = nil;
	BOOL success = [[state writeToURL:URL] waitUntilCompleted:&error];
	expect(success).to.beTruthy();
	expect(error).to.beNil();

	SQRLShipItState *readState = [[SQRLShipItState readFromURL:URL] firstOrDefault:nil success:&success error:&error];
	expect(success).to.beTruthy();
	expect(error).to.beNil();

	expect(readState).to.equal(state);
});

SpecEnd
