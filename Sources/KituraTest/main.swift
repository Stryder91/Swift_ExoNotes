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
    "Bob" : [11,10,11,11,14],
    "Xavier" : [4,10,11,14,6],
    "Bip" : [5,14,14,6,18],
    "Bobi" : [6,12,9,11,13],
    "Bernard" : [16,14,20,14,12],
    "Matthieu" : [1,18,12,17,5,19],
]

router.get("/") { request, response, next in
    try response.render("Home.stencil", context: ["greeting" : "Bienvenue dans la fameuse classe"])
    next()
}

router.post("/eleves") { request, response, next in
    if let body = request.body?.asURLEncoded { 
        if let name = body["name"]{
            var eleves : [String] = []
            
            for (eleve, note) in classe {
                if eleve.contains(name) {
                    eleves.append(eleve)
                }
            } 
        try response.render("Class.stencil", context: ["class" : eleves])
        }
    next()
    }
    else {
       response.status(.notFound)
    }
    next()
}
func get_moyenne(notes: [Int]) -> Int{
    var moyenne : Int = 0
    for note in notes {
        moyenne += note
    }
    moyenne = moyenne / notes.count
    return moyenne
}
func get_mediane(notes: [Int]) -> Int {
    var mediane : Int
    //Tri du tableau afin de trouver la médiane
    var tableauTrie : [Int] = notes.sorted()
    mediane = tableauTrie[tableauTrie.count / 2]
    return mediane
}
func get_ecartType(notes: [Int], moyenne: Int) -> Double {
    var sous_variance : Int
    var variance : Int = 0
    var ecart_type : Double = 0
    for note in notes {
            sous_variance = note - moyenne
            print(sous_variance)
            variance += (sous_variance * sous_variance)
        }
    ecart_type = Double(variance).squareRoot()
    return ecart_type
}
router.get("/eleves/:name") { request, response, next in
    //Déclarations
    var notes : [Int] = []
    var moyenne : Int = 0

    if let name = request.parameters["name"]{
        notes = classe[name]! 
        //On passe les appels aux fonctions directement dans le context
        try response.render("Bulletin.stencil", context: ["bulletin" : notes, "eleve": name, 
        "moyenne":get_moyenne(notes:notes), 
        "mediane":get_mediane(notes:notes), 
        "ecart_type":get_ecartType(notes:notes, moyenne:get_moyenne(notes:notes))])
    }
}


Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
