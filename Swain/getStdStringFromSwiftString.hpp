//
//  getStdStringFromSwiftString.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/25/24.
//

#ifndef getStdStringFromSwiftString_hpp
#define getStdStringFromSwiftString_hpp

#import <CoreFoundation/CoreFoundation.h>
#include <string>
@import SwainCore;

std::string getStdStringFromSwiftString(swift::String string);
CFStringRef getCFStringFromSwiftString(swift::String string);

#endif /* getStdStringFromSwiftString_hpp */
