//
//  getStringFromSwiftString.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/25/24.
//

#import <CoreFoundation/CoreFoundation.h>
#include <string>
@import SwainCore;

std::string getStdStringFromSwiftString(swift::String string);
CFStringRef getCFStringFromSwiftString(swift::String string);
