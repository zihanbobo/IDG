// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import <ProtocolBuffers/ProtocolBuffers.h>

#import "Header.pb.h"
// @@protoc_insertion_point(imports)

@class Attachment;
@class AttachmentBuilder;
@class Header;
@class HeaderBuilder;
@class IMMessage;
@class IMMessageBuilder;



@interface ImmessageRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

#define IMMessage_header @"header"
#define IMMessage_body @"body"
@interface IMMessage : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasHeader_:1;
  BOOL hasBody_:1;
  Header* header;
  NSData* body;
}
- (BOOL) hasHeader;
- (BOOL) hasBody;
@property (readonly, strong) Header* header;
@property (readonly, strong) NSData* body;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (IMMessageBuilder*) builder;
+ (IMMessageBuilder*) builder;
+ (IMMessageBuilder*) builderWithPrototype:(IMMessage*) prototype;
- (IMMessageBuilder*) toBuilder;

+ (IMMessage*) parseFromData:(NSData*) data;
+ (IMMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IMMessage*) parseFromInputStream:(NSInputStream*) input;
+ (IMMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (IMMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (IMMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface IMMessageBuilder : PBGeneratedMessageBuilder {
@private
  IMMessage* resultImmessage;
}

- (IMMessage*) defaultInstance;

- (IMMessageBuilder*) clear;
- (IMMessageBuilder*) clone;

- (IMMessage*) build;
- (IMMessage*) buildPartial;

- (IMMessageBuilder*) mergeFrom:(IMMessage*) other;
- (IMMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (IMMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasHeader;
- (Header*) header;
- (IMMessageBuilder*) setHeader:(Header*) value;
- (IMMessageBuilder*) setHeaderBuilder:(HeaderBuilder*) builderForValue;
- (IMMessageBuilder*) mergeHeader:(Header*) value;
- (IMMessageBuilder*) clearHeader;

- (BOOL) hasBody;
- (NSData*) body;
- (IMMessageBuilder*) setBody:(NSData*) value;
- (IMMessageBuilder*) clearBody;
@end


// @@protoc_insertion_point(global_scope)
