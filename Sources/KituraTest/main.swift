import Kitura
import HeliumLogger
import KituraStencil

import Foundation

HeliumLogger.use()

let router = Router()

router.all(middleware: BodyParser())
router.all(middleware: [BodyParser(), StaticFileServer(path: "./Public")])
router.add(templateEngine: StencilTemplateEngine())

let classe : [String : [Int] ] = [
    "Matheus" : [15,7,14,6,12],
    "Lionel" : [16,14,10,11,12],
    "Matt" : [8,14,19,14,10],
    "Lili": [6,10,17,12,12],
    "Bob" : [11,14,10,13,8],
    "Xavier" : [4,10,11,14,6],
    "Bip" : [5,14,14,6,18],
    "Bobi" : [6,12,9,11,13],
    "Bernard" : [16,14,20,14,12],
    "Matthieu" : [1,18,12,17,5,19],
]

router.get("/") { request, response, next in
    try response.render("Home.stencil", context: ["greeting" : "hello"])
    next()
}

router.post("/eleves") { request, response, next in
    if let body = request.body?.asURLEncoded { 
        if let name = body["name"]{
            print(name)
            var eleves : [String] = []
            
            for (eleve, note) in classe {
                if eleve.contains(name) {
                    print("exists", eleve)
                    eleves.append(eleve)
                }
            } 
            for eleve in eleves {
                print(eleve)
            }
        try response.render("Class.stencil", context: ["class" : eleves])
        }
        //response.send("<li><form action='/eleve' method='get'><input type='hidden' value'\(eleve)' placeholder='\(eleve)' name='name'/> <button type='submit'>\(eleve)</button></form></li>")
    next()
    }
    else {
       response.status(.notFound)
    }
    next()
}
router.get("/eleves/:name") { request, response, next in
    var mediane : Int
    var ecart_type : Double = 0
    var variance : Int = 0
    var sous_variance : Int 
    var moyenne : Int = 0
    var notes : [Int] = []
    if let name = request.parameters["name"]{
        notes = classe[name] ?? [10,10]
        for note in notes {
            moyenne += note
        }
        var tableauTrie : [Int] = notes.sorted()
        moyenne = moyenne / notes.count
        for element in tableauTrie {
            sous_variance = element - moyenne
            print(variance)
            variance += (sous_variance * sous_variance)
        }
        ecart_type = Double(variance).squareRoot()
        mediane = tableauTrie[tableauTrie.count / 2]
        try response.render("Bulletin.stencil", context: ["bulletin" : notes, "eleve": name, "moyenne":moyenne, "mediane":mediane, "ecart_type":ecart_type])
    }
}


Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
