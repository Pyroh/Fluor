//
//  ReleaseNotesWindowController.swift
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


import Cocoa

class ReleaseNotesWindowController: NSWindowController, NSWindowDelegate, StoryboardInstantiable {
    static var storyboardName: NSStoryboard.Name { .about }
    static var sceneIdentifier: NSStoryboard.SceneIdentifier? { "RNWC" }
    
    @objc dynamic var releases: [Release] = []
    private var session: URLSession?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.populateList()
    }
    
    override func cancelOperation(_ sender: Any?) {
        window?.close()
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        self.session?.invalidateAndCancel()
    }
    
    // MARK: - Actions
    
    @IBAction func changeVersion(_ sender: NSPopUpButton) {
        guard let release = sender.selectedItem?.representedObject as? Release else { fatalError() }
        self.show(url: release.url)
    }
    
    // MARK: - Private functions
    
    private func populateList() {
        guard let str = Bundle.main.infoDictionary?["FLRNListURL"] as? String,
            let url = URL(string: str) else {
                fatalError("No RN String !")
        }
        
        self.session = URLSession(configuration: .ephemeral)
        
        self.session?.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { [unowned self] in
                    self.presentError(error, modalFor: self.window!, delegate: nil, didPresent: nil, contextInfo: nil)
                }
            } else if let data = data {
                do {
                    let entries = try JSONDecoder().decode([Release].self, from: data)
                    DispatchQueue.main.async {
                        [unowned self] in self.releases = entries
                        if let last = entries.first {
                            self.show(url: last.url)
                        }
                    }
                } catch {
                    DispatchQueue.main.async { [unowned self] in
                        self.presentError(error, modalFor: self.window!, delegate: nil, didPresent: nil, contextInfo: nil)
                    }
                }
            }
        }).resume()
    }
    
    private func show(url: URL) {
        guard let ctrl = self.contentViewController as? ReleaseNotesViewController else { fatalError() }
        ctrl.show(url: url)
    }
}
