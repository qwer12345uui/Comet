#import <Foundation/Foundation.h>

#if __has_include(<roothide.h>)
#import <roothide.h>
#define COMET_HAS_ROOTHIDE 1
#else
#define COMET_HAS_ROOTHIDE 0
#endif

static inline NSString *CometJailbreakPath(NSString *path) {
    if (path.length == 0 || ![path hasPrefix:@"/"]) {
        return path;
    }

#if COMET_HAS_ROOTHIDE && defined(ROOTHIDE)
    return jbroot(path);
#elif defined(ROOTLESS)
    return [@"/var/jb" stringByAppendingString:path];
#else
    return path;
#endif
}
