//
//  ReleaseNotesWindowController.swift
//  Fluor
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
