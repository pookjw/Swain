//
//  getStdStringFromSwiftString.cpp
//  Swain
//
//  Created by Jinwoo Kim on 1/25/24.
//

#import "getStdStringFromSwiftString.hpp"
#include <ranges>
#include <string>

std::string getStdStringFromSwiftString(swift::String string) {
    std::string result {};
    
    swift::UTF8View utf8View = string.getUtf8();
    swift::String_Index startIndex = utf8View.getStartIndex();
    swift::String_Index endIndex = utf8View.getEndIndex();
    
    // __fatalError_Cxx_move_of_Swift_value_type_not_supported_yet
    auto ptr = &utf8View;
    
    std::ranges::for_each(std::views::iota(startIndex.getEncodedOffset(), endIndex.getEncodedOffset()), [&result, ptr](auto i) {
        swift::String_Index index = swift::String_Index::init(i);
        auto c = static_cast<const char>((*ptr)[index]);
        
        result.append(std::string {c});
    });
    
    return result;
}

CFStringRef getCFStringFromSwiftString(swift::String string) {
    CFMutableStringRef result = CFStringCreateMutable(kCFAllocatorDefault, string.getCount());
    
    swift::UTF8View utf8View = string.getUtf8();
    swift::String_Index startIndex = utf8View.getStartIndex();
    swift::String_Index endIndex = utf8View.getEndIndex();
    
    // __fatalError_Cxx_move_of_Swift_value_type_not_supported_yet
    auto ptr = &utf8View;
    
    std::ranges::for_each(std::views::iota(startIndex.getEncodedOffset(), endIndex.getEncodedOffset()), [result, ptr](auto i) {
        swift::String_Index index = swift::String_Index::init(i);
        auto c = static_cast<const char>((*ptr)[index]);
        char str[2] = {c, '\0'};
        
        CFStringRef substring = CFStringCreateWithCString(kCFAllocatorDefault, str, kCFStringEncodingUTF8);
        CFStringAppend(result, substring);
        CFRelease(substring);
    });
    
    CFStringRef copy = CFStringCreateCopy(kCFAllocatorDefault, result);
    CFRelease(result);
    
    return reinterpret_cast<CFStringRef>(CFAutorelease(copy));
}
