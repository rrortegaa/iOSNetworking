import UIKit

/*
 OBJETIVO
 1. Hacer el Modelado de datos
 2. Crear una estructura de datos con información contenida dentro de un JSON
 3. Hacer una petición con URL Session
 
 1. Obtener URL, analizar e identificar los tipos de datos
 2. Crear una estructura con los tipos de datos, ocupar Enum en el caso de necesitar cambiar type case de alguna de las keys en el JSON, los nombres de las variables del Struct deben coincidir con los del JSON
 3. Conformar nuestro Struct con el protocolo Codable
 4. Hacer la petición con URLSession
 
 URLSession
 1. Tener una URL
 2. Crear la URLSession.shared
 3. Asignar la tarea dataTask
 4. JSONDecoder() aqui usamos nuestra estructura de datos
 5. Ejecutar la tarea
 
*/


struct ToDo: Codable {
    var id: Int
    var todo: String
    var completed: Bool
    var userId: Int
}

struct ToDos: Codable {
    var todos: [ToDo]
    var total: Int
    var skip: Int
    var limit: Int
}

let urlSession = URLSession.shared
guard let url = URL(string: "https://dummyjson.com/todos") else {
    fatalError("URL not valid")
}

let dataTask = urlSession.dataTask(with: url) {
    data, response, error in
    guard let data = data else { return }
    let jsonDecoder = JSONDecoder()
    guard let todoList = try? jsonDecoder.decode(ToDos.self, from: data) else { return }
    print("Todo List form dummyjson.com:")
    print(todoList.todos)
    print("-----")
}
dataTask.resume()
