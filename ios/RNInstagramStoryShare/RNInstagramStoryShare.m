#import "RCTBridgeModule.h"

#import "RNInstagramStoryShare.h"
#if __has_include(<React/RCTConvert.h>)

#import <React/RCTConvert.h>
#elif __has_include("RCTConvert.h")

#import "RCTConvert.h"
#else

#import "React/RCTConvert.h"
#endif

@implementation RNInstagramStoryShare

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

RCT_EXPORT_METHOD(share: (NSDictionary *)options
                resolve: (RCTPromiseResolveBlock)resolve
                reject: (RCTPromiseRejectBlock)reject) {									

	NSString *provider  						= [RCTConvert NSString:options[@"provider"]];
	NSString *appID  								= [RCTConvert NSString:options[@"appId"]];
	NSURL *backgroundImageParam  		= [RCTConvert NSURL:options[@"backgroundImage"]];
	NSURL *backgroundVideoParam  		= [RCTConvert NSURL:options[@"backgroundVideo"]];
	NSURL *stickerImageParam     		= [RCTConvert NSURL:options[@"stickerImage"]];
	NSString *backgroundTopColor    = [RCTConvert NSString:options[@"backgroundTopColor"]];
	NSString *backgroundBottomColor = [RCTConvert NSString:options[@"backgroundBottomColor"]];
	NSString *contentURL            = [RCTConvert NSString:options[@"contentURL"]];


	NSString *dataError    = @"data conversion failed";
	NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(dataError, nil)};
	NSError *error         = [NSError errorWithDomain:@"com.rninstagramstoryshare" code:1 userInfo:userInfo];

  NSData *backgroundImage = nil;
	if (backgroundImageParam) {
		backgroundImage = [NSData dataWithContentsOfURL:backgroundImageParam
																						options:(NSDataReadingOptions)0
																					 		error:&error];
		if (!backgroundImage) {
			reject(RCTErrorUnspecified, dataError, error);
			return;
		}
		backgroundImage = UIImagePNGRepresentation([UIImage imageWithData:backgroundImage]);
	}

  NSData *backgroundVideo = nil;
	if (backgroundVideoParam) {
		backgroundVideo = [[NSFileManager defaultManager] contentsAtPath:backgroundVideoParam];
		if (!backgroundVideo) {
			reject(RCTErrorUnspecified, dataError, error);
			return;
		}
	}

  NSData *stickerImage = nil;
	if (stickerImageParam) {
		stickerImage = [NSData dataWithContentsOfURL:stickerImageParam
																				 options:(NSDataReadingOptions)0
																					 error:&error];
		if (!stickerImage) {
			reject(RCTErrorUnspecified, dataError, error);
			return;
		}
		stickerImage = UIImagePNGRepresentation([UIImage imageWithData:stickerImage]);
	}    

	[self 			 provider: provider
									appID: appID
				backgroundImage: backgroundImage
				backgroundVideo: backgroundVideo
					 stickerImage: stickerImage
		 backgroundTopColor: backgroundTopColor
	backgroundBottomColor: backgroundBottomColor
						 contentURL: contentURL
								resolve: resolve
								 reject: reject];
}

- (void) 				provider: (NSString *)provider
									 appID: (NSString *)appID
				 backgroundImage: (NSData *)backgroundImage
				 backgroundVideo: (NSData *)backgroundVideo
				    stickerImage: (NSData *)stickerImage
			backgroundTopColor: (NSString *)backgroundTopColor
	 backgroundBottomColor: (NSString *)backgroundBottomColor
				      contentURL: (NSString *)contentURL
				         resolve: (RCTPromiseResolveBlock)resolve
				          reject: (RCTPromiseRejectBlock)reject {

	NSString *url    = [NSString stringWithFormat: @"%@-stories://share", provider];
	NSURL *urlScheme = [NSURL URLWithString: url];

	NSDictionary *dictionary               = @{}; 
	NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];

	if ([provider isEqualToString:@"facebook"]) {
		if (appID) {
			NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.appID", provider];
			mutableDictionary[key] = appID;
		}
	}

	if (backgroundImage) {
		NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.backgroundImage", provider];
		mutableDictionary[key] = backgroundImage;
	}

	if (backgroundVideo) {
		NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.backgroundVideo", provider];
		mutableDictionary[key] = backgroundVideo;
	}

	if (stickerImage) {
		NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.stickerImage", provider];
		mutableDictionary[key] = stickerImage;
	}

	if (backgroundTopColor) {
		NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.backgroundTopColor", provider];
		mutableDictionary[key] = backgroundTopColor;
	}
	
	if (backgroundBottomColor) {
		NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.backgroundBottomColor", provider];
		mutableDictionary[key] = backgroundBottomColor;
	}

	if (contentURL) {
		NSString *key          = [NSString stringWithFormat: @"com.%@.sharedSticker.contentURL", provider];
		mutableDictionary[key] = contentURL;
	}
	
	NSArray *pasteboardItems = @[mutableDictionary];

	if (@available(iOS 10.0, *)) {
		NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
		[[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
		[[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
	} else {
		[[UIPasteboard generalPasteboard] setItems:pasteboardItems];
		[[UIApplication sharedApplication] openURL:urlScheme];
	}
}

@end