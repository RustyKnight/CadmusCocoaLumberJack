//
//  LoggerConfig.swift
//  MarconiAPIService
//
//  Created by Shane Whitehead on 19/11/18.
//  Copyright © 2018 BeamCommunications. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

/**
Provides a LogLevel Configuration
*/
public enum LogLevel {
	
	/**
	Provides LogLevel
	
	- returns: Returns the current LogLevel
	*/
	case none, error, warning, info, verbose, debug, all
	
	/**
	Get the current LogLevel
	
	- returns: DDLogLevel
	*/
	func getDDLogLevel() -> DDLogLevel {
		switch self {
    case .none: return DDLogLevel.off
		case .error: return DDLogLevel.error
		case .warning: return DDLogLevel.warning
		case .info: return DDLogLevel.info
		case .verbose: return DDLogLevel.verbose
    case .debug: return DDLogLevel.debug
    case .all: return DDLogLevel.all
		}
	}
}

public struct LogTargetConfig {
  public let isEnabled: Bool
  public let level: LogLevel
  
  public init(isEnabled: Bool = true, level: LogLevel = .verbose) {
    self.isEnabled = isEnabled
    self.level = level
  }
}

public struct LogConfig {
  
  public let console: LogTargetConfig
  public let file: LogTargetConfig
  
	public init(console: LogTargetConfig = LogTargetConfig(),
              file: LogTargetConfig = LogTargetConfig()) {
    self.console = console
    self.file = file
	}
}
