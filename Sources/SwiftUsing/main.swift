/**
 *  SwiftUsing
 *  Copyright (c) Alejandro Martínez 2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import SwiftUsingCore
import Foundation
import Yaap

class GenerateCommand: Command {
    let name = "Generate"
    
    let path = Argument<String>(documentation: "Path to the file to execute the code generation on.")
    
    func run(outputStream: inout TextOutputStream, errorStream: inout TextOutputStream) throws {
        outputStream.write("Generating code...\n")
        
        let file = URL(fileURLWithPath: path.value)
        
        let generator = SwiftUsing(file: file)
        try generator.generate()
    }
}

GenerateCommand().parseAndRun()
