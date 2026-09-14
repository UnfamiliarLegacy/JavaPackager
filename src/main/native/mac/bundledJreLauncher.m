#import <Foundation/Foundation.h>
#import <unistd.h>

int main(int argc, char **argv) {
	@autoreleasepool {
		NSBundle *bundle = [NSBundle mainBundle];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *pluginsPath = [bundle builtInPlugInsPath];
		NSString *javaHome = nil;

		for (NSString *entry in [fileManager contentsOfDirectoryAtPath:pluginsPath error:nil]) {
			if (![[entry pathExtension] isEqualToString:@"jre"]) {
				continue;
			}

			NSString *candidate = [[pluginsPath stringByAppendingPathComponent:entry]
				stringByAppendingPathComponent:@"Contents/Home"];
			if ([fileManager isExecutableFileAtPath:[candidate stringByAppendingPathComponent:@"bin/java"]]) {
				javaHome = candidate;
				break;
			}
		}

		if (javaHome == nil) {
			NSLog(@"Bundled Java runtime is missing or invalid in %@", pluginsPath);
			return 1;
		}

		if (setenv("JAVA_HOME", [javaHome fileSystemRepresentation], 1) != 0) {
			perror("Unable to set JAVA_HOME");
			return 1;
		}

		NSString *launcherPath = [[bundle executablePath] stringByAppendingString:@".bin"];
		execv([launcherPath fileSystemRepresentation], argv);
		perror("Unable to start the application launcher");
		return 1;
	}
}
