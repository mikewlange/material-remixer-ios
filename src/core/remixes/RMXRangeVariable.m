/*
 Copyright 2016-present Google Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RMXRangeVariable.h"

#import "RMXRemixer.h"

@implementation RMXRangeVariable

+ (instancetype)rangeVariableWithKey:(NSString *)key
                        defaultValue:(CGFloat)defaultValue
                            minValue:(CGFloat)minValue
                            maxValue:(CGFloat)maxValue
                           increment:(CGFloat)increment
                         updateBlock:(RMXNumberUpdateBlock)updateBlock {
  RMXRangeVariable *variable = [[self alloc] initWithKey:key
                                            defaultValue:defaultValue
                                                minValue:minValue
                                                maxValue:maxValue
                                               increment:increment
                                             updateBlock:updateBlock];
  return [RMXRemixer addVariable:variable];
}

+ (instancetype)rangeVariableWithKey:(NSString *)key
                        defaultValue:(CGFloat)defaultValue
                         updateBlock:(RMXNumberUpdateBlock)updateBlock {
  // These default values are just temporary. We change them to the right values as soon as we
  // get the data from the cloud service.
  RMXRangeVariable *variable = [[self alloc] initWithKey:key
                                            defaultValue:defaultValue
                                                minValue:defaultValue
                                                maxValue:defaultValue
                                               increment:0
                                             updateBlock:updateBlock];
  return [RMXRemixer addVariable:variable];
}

+ (instancetype)variableFromDictionary:(NSDictionary *)dictionary {
  NSString *key = [dictionary objectForKey:RMXDictionaryKeyKey];
  CGFloat selectedValue = [[dictionary objectForKey:RMXDictionaryKeySelectedValue] floatValue];
  CGFloat minValue = [[dictionary objectForKey:RMXDictionaryKeyMinValue] floatValue];
  CGFloat maxValue = [[dictionary objectForKey:RMXDictionaryKeyMaxValue] floatValue];
  CGFloat increment = [[dictionary objectForKey:RMXDictionaryKeyIncrement] floatValue];
  return [[self alloc] initWithKey:key
                      defaultValue:selectedValue
                          minValue:minValue
                          maxValue:maxValue
                         increment:increment
                       updateBlock:nil];
}

- (void)updateToStoredVariable:(RMXRangeVariable *)storedVariable {
  self.minimumValue = storedVariable.minimumValue;
  self.maximumValue = storedVariable.maximumValue;
  self.increment = storedVariable.increment;
  [super updateToStoredVariable:storedVariable];
}

- (NSDictionary *)toJSON {
  NSMutableDictionary *json = [super toJSON];
  json[RMXDictionaryKeySelectedValue] = @(self.selectedFloatValue);
  json[RMXDictionaryKeyMinValue] = @(self.minimumValue);
  json[RMXDictionaryKeyMaxValue] = @(self.maximumValue);
  json[RMXDictionaryKeyIncrement] = @(self.increment);
  return json;
}

#pragma mark - Private

- (instancetype)initWithKey:(NSString *)key
               defaultValue:(CGFloat)defaultValue
                   minValue:(CGFloat)minValue
                   maxValue:(CGFloat)maxValue
                  increment:(CGFloat)increment
                updateBlock:(RMXNumberUpdateBlock)updateBlock {
  self = [super initWithKey:key
             typeIdentifier:RMXTypeRange
               defaultValue:@(defaultValue)
                updateBlock:^(RMXVariable *_Nonnull variable, id _Nonnull selectedValue) {
                  updateBlock((RMXNumberVariable *)variable, [selectedValue floatValue]);
                }];
  if (self) {
    _minimumValue = minValue;
    _maximumValue = maxValue;
    _increment = increment;
    self.controlType = increment > 0 ? RMXControlTypeStepper : RMXControlTypeSlider;
  }
  return self;
}

@end
