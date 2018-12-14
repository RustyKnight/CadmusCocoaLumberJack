//
//  LoggerService.swift
//  MarconiAPIService
//
//  Created by Shane Whitehead on 19/11/18.
//  Copyright © 2018 BeamCommunications. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
import Cadmus

/**
Initialzes CocoaLumberjack
*/

@objc public class LumberJackLogService: NSObject, CadmusDelegate {
	
	/// Shared LogService
	public static let shared = LumberJackLogService()
	
	public var fileLogsPath: String? = nil

	static let maximumLogFileSize: UInt64 = 1024 * 1024 * 10
	static let rollingFrequency: TimeInterval = 24.0 * 60.0 * 60.0
	static let maximumNumberOfLogFiles: UInt = 7

	public let logFileManager: DDLogFileManager = DDLogFileManagerDefault.init()
	
	override init() {
		super.init()
		CadmusService.shared.delegate = self
	}
	
	/**
	Initializes the LogService based on the Configuration provided
	
	- Parameters:
	- config: Log Config
	*/
	public func initialize(config: LogConfig) {
    configureConsoleLogging(config: config.console)
    configureFileLogging(config: config.file)
		Cadmus.log(debug: "Initialized Log Service")
	}
	
	/**
	Configures File Logging

	- Parameters:
	- config: Log Config
	*/
	func configureFileLogging(config: LogTargetConfig) {
    guard !config.isEnabled else {
      return
    }
		// File Logger
		let fileLogger: DDFileLogger = DDFileLogger()
		fileLogger.logFormatter = LogFormatter()

		// Set the Log file rolling frequency based on the maximum file size (2MB)
		fileLogger.maximumFileSize = LumberJackLogService.maximumLogFileSize
		fileLogger.rollingFrequency = LumberJackLogService.rollingFrequency
		// Maximum number of archived logs to be kept on disk
		fileLogger.logFileManager.maximumNumberOfLogFiles = LumberJackLogService.maximumNumberOfLogFiles

		DDLog.add(fileLogger, with: config.level.getDDLogLevel())
		fileLogsPath = fileLogger.logFileManager.logsDirectory
		Cadmus.log(debug: "Configured File Logging \(String(describing: fileLogger.logFileManager.logsDirectory))")
	}

	/**
	Configures Console Logging

	- Parameters:
	- config: Log Config
	*/
	func configureConsoleLogging(config: LogTargetConfig) {
    guard !config.isEnabled else {
      return
    }
		DDTTYLogger.sharedInstance.logFormatter = LogFormatter()
		DDTTYLogger.sharedInstance.colorsEnabled = false

		// Log to Xcode console
		DDLog.add(DDTTYLogger.sharedInstance, with: config.level.getDDLogLevel())
		Cadmus.log(debug: "Configured Console Logging")
	}

	/**
	Logs verbose messages
	- Parameters:
	- message: Message
	*/
	public func log(verbose: String, file: StaticString, function: StaticString, line: UInt) {
		DDLogVerbose(verbose, file: file, function: function, line: line)
	}

	public func log(verbose: CustomStringConvertible, file: StaticString, function: StaticString, line: UInt) {
		log(verbose: verbose.description, file: file, function: function, line: line)
	}

	/**
	Logs info messages
	- Parameters:
	- message: Message
	*/
	public func log(info: String, file: StaticString, function: StaticString, line: UInt) {
		DDLogInfo(info, file: file, function: function, line: line)
	}

	public func log(info: CustomStringConvertible, file: StaticString, function: StaticString, line: UInt) {
		log(info: info.description, file: file, function: function, line: line)
	}

	/**
	Logs warning messages
	- Parameters:
	- message: Message
	*/
	public func log(warning: String, file: StaticString, function: StaticString, line: UInt) {
		DDLogWarn(warning, file: file, function: function, line: line)
	}

	public func log(warning: Error, file: StaticString, function: StaticString, line: UInt) {
		log(warning: "\(warning)", file: file, function: function, line: line)
	}

	public func log(warning: CustomStringConvertible, file: StaticString, function: StaticString, line: UInt) {
		log(warning: warning.description, file: file, function: function, line: line)
	}

	/**
	Logs Error Messages
	- Parameters:
	- message: Message
	*/
	public func log(error: String, file: StaticString, function: StaticString, line: UInt) {
		DDLogError(error, file: file, function: function, line: line)
	}

	public func log(error: Error, file: StaticString, function: StaticString, line: UInt) {
		log(warning: "\(error)", file: file, function: function, line: line)
	}

	public func log(error: CustomStringConvertible, file: StaticString, function: StaticString, line: UInt) {
		log(error: error.description, file: file, function: function, line: line)
	}

	/**
	Logs debug Messages
	- Parameters:
	- message: Message
	*/

	public func log(debug: String, file: StaticString, function: StaticString, line: UInt) {
		DDLogDebug(debug, file: file, function: function, line: line)
	}

	public func log(debug: CustomStringConvertible, file: StaticString, function: StaticString, line: UInt) {
		log(debug: debug.description, file: file, function: function, line: line)
	}
}


class LogFormatter: NSObject, DDLogFormatter {
	
	lazy var dateTimeFormatter: DateFormatter = {
		let df = DateFormatter()
		df.locale = Locale(identifier: "en_AU")
		df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSZ"
		return df
	}()
	
	func format(message logMessage: DDLogMessage) -> String? {
		var logLevel: String
		let logFlag = logMessage.flag
		if logFlag.contains(.error) {
			logLevel = "⛔️"
		} else if logFlag.contains(.warning) {
			logLevel = "⚠️"
		} else if logFlag.contains(.info) {
			logLevel = "💡"
		} else if logFlag.contains(.debug) {
			logLevel = "🐞"
		} else if logFlag.contains(.verbose) {
			logLevel = "💬"
		} else {
			logLevel = "?"
		}
		
		var function = "Unknown"
		if let functionName = logMessage.function {
			function = functionName
		}
		let dateText = dateTimeFormatter.string(from: logMessage.timestamp)
		
		return "\(logLevel) [\(dateText)][\(logMessage.threadID):\(logMessage.queueLabel)][\(logMessage.fileName) \(function)] #\(logMessage.line): \(logMessage.message)"
	}
}

