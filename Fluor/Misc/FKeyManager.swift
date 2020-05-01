//
//  FKeyManager.swift
// 
//  Fluor
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


enum FKeyManager {
    typealias FKeyManagerResult = Result<FKeyMode, Error>
    
    enum FKeyManagerError: Error {
        case cannotCreateMasterPort
        case cannotOpenService
        case cannotSetParameter
        case cannotGetParameter
        
        case otherError
        
        var localizedDescription: String {
            switch self {
            case .cannotCreateMasterPort:
                return "Master port creation failed (E1)"
            case .cannotOpenService:
                return "Service opening failed (E2)"
            case .cannotSetParameter:
                return "Parameter set not possible (E3)"
            case .cannotGetParameter:
                return "Parameter read not possible (E4)"
            default:
                return "Unknown error (E99)"
            }
        }
    }
    
    static func setCurrentFKeyMode(_ mode: FKeyMode) throws {
        let connect = try FKeyManager.getServiceConnect()
        let value = mode.rawValue as CFNumber
        
        guard IOHIDSetCFTypeParameter(connect, kIOHIDFKeyModeKey as CFString, value) == KERN_SUCCESS else {
            throw FKeyManagerError.cannotSetParameter
        }
        
        IOServiceClose(connect)
    }
    
    static func getCurrentFKeyMode() -> FKeyManagerResult {
        FKeyManagerResult {
            let ri = try self.getIORegistry()
            defer { IOObjectRelease(ri) }
            
            let entry = IORegistryEntryCreateCFProperty(ri, "HIDParameters" as CFString, kCFAllocatorDefault, 0).autorelease()
            
            guard let dict = entry.takeUnretainedValue() as? NSDictionary,
                let mode = dict.value(forKey: "HIDFKeyMode") as? Int,
                let currentMode = FKeyMode(rawValue: mode) else {
                    throw FKeyManagerError.cannotGetParameter
            }
            
            return currentMode
        }
    }
    
    private static func getIORegistry() throws -> io_registry_entry_t {
        var masterPort: mach_port_t = .zero
        guard IOMasterPort(bootstrap_port, &masterPort) == KERN_SUCCESS else { throw FKeyManagerError.cannotCreateMasterPort }
        
        return IORegistryEntryFromPath(masterPort, "IOService:/IOResources/IOHIDSystem")
    }
    
    private static func getIOHandle() throws -> io_service_t {
        try self.getIORegistry() as io_service_t
    }
    
    private static func getServiceConnect() throws -> io_connect_t {
        var service: io_connect_t = .zero
        let handle = try self.getIOHandle()
        defer { IOObjectRelease(handle) }
        
        guard IOServiceOpen(handle, mach_task_self_, UInt32(kIOHIDParamConnectType), &service) == KERN_SUCCESS else {
            throw FKeyManagerError.cannotOpenService
        }
        
        return service
    }
}
