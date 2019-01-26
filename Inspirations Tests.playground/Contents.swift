import Cocoa




let alert = NSAlert.init()
alert.informativeText="blabsda jbs dbas"
alert.alertStyle = .informational
alert.addButton(withTitle: "ok")
//alert.beginSheetModal(for: NSApp.keyWindow, completionHandler: nil)
//self.init()
//self.messageText="Map the key"
//self.informativeText="Please select the key that should be used to assign the value of \(withPopUpFrom.first)"
//self.alertStyle = .informational
//let keyPopUp=NSPopUpButton.init(title: "test", target: nil, action: nil)
//self.accessoryView=keyPopUp
//self.addButton(withTitle: "OK")
//self.addButton(withTitle: "Cancel")

var str = "Hello, playground"
let myURL = URL(fileURLWithPath: "/Users/Gonche/Desktop/exportedOnFeb24-sample.txt")
var testData=Data()
do{
    testData = try Data.init(contentsOf: myURL)
}catch{
    print(error)
}

let tempDictArray = try? JSONSerialization.jsonObject(with: testData, options: [])
let dictArrayDirty = tempDictArray as? [[String:Any]]

func getAllPossibleKeys(dictionaryArray:[[String:Any]])->[String]{
    var outArray=[String]()
    //Asign keys from current array.
    outArray.append(contentsOf: dictionaryArray.flatMap({$0.keys}))
    
    //Checks if any value is a dictionary and assigns key.
    let valuesDict=dictionaryArray.flatMap({$0.values})
    valuesDict.forEach{ item in
        //Value is a dictionary:
        if let dict=item as? [String:Any]{
            outArray.append(contentsOf: getAllPossibleKeys(dictionaryArray: [dict]))
        }
        //value is an array:
        if let arrayOfDict=item as? [[String:Any]]{
            outArray.append(contentsOf: getAllPossibleKeys(dictionaryArray: arrayOfDict))
        }
    }
    
    return Array(Set(outArray))
}
let myKeys=getAllPossibleKeys(dictionaryArray: dictArrayDirty!)


//MARK: - Machine learning
////Langugage ID:
//let quote = "Que voy a hacer"
//
//let tagger = NSLinguisticTagger(tagSchemes: [.language, .lemma, .lexicalClass, .script], options: 0)
//
//tagger.string=quote
//print(tagger.dominantLanguage)
//
//NSLinguisticTagger.dominantLanguage(for: "Que voy a hacer")
//
////ML Model:
//import CreateML
//
//let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/Gonche/Desktop/ML.json"))
//print(data.rows.count)
//let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
//let topicClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "topic")
//
//// Training/Validation accuracy as a percentage
//let trainingAccuracy = (1.0 - topicClassifier.trainingMetrics.classificationError) * 100
//let validationAccuracy = (1.0 - topicClassifier.validationMetrics.classificationError) * 100
//
//let evaluationMetrics = topicClassifier.evaluation(on: testingData)
//let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
//
//try topicClassifier.prediction(from: "To love is to loose")
//try topicClassifier.prediction(from: "Shoot for the moon, even if you miss you will land among the stars")
//try topicClassifier.prediction(from: "To live is to die")
//
//let metadata = MLModelMetadata(author: "Andres Gonzalez Casabianca",
//                               shortDescription: "A model trained to do topic modeling on the quotes",
//                               version: "1.0",
//                               additional:["records":"5420"])
//
//try topicClassifier.write(to: URL(fileURLWithPath: "/Users/Gonche/Desktop/TopicModeling.mlmodel"),
//                          metadata: metadata)
////import NaturalLanguage
//
////let sentimentPredictor = try NLModel(mlModel: SentimentClassifier().model)
////sentimentPredictor.predictedLabel(for: "It was the best I've ever seen!")
