import UIKit

func getFileURL(withName name: String, andExtension fileExtension: String) -> URL? {
    guard let jsonFileURL = Bundle.main.url(
        forResource: name,
        withExtension: fileExtension
    ) else {
        print("Could not locate file \(name).\(fileExtension)")
        return nil
    }
    return jsonFileURL
}

// Creamos estructura y "heredamos" de Codable
struct Post: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

/* Guard Let Example

 var optional: Int?
 
 guard let nonOptionalValue = optional else {
    optional is nil
    return
 }
 optional is not nil
 
*/

// Obtenemos URL del archivo json
if let jsonURL = getFileURL(withName: "Post", andExtension: "json") {
    guard let jsonData = try? Data(contentsOf: jsonURL) else {
        fatalError("Could not gather data from file")
    }
    
    let jsonDecoder = JSONDecoder()
    
    guard let post = try? jsonDecoder.decode(Post.self, from: jsonData) else {
        fatalError("Could not parse data")
    }
    print("Content in Post JSON:")
    print(post)
    print(post.id)
    print(post.title)
    print("-----")
}



struct Comment: Codable {
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_Id"
        case id
        case name
        case email
        case body
    }
    
    var postId: Int
    var id: Int
    var name: String
    var email: String
    var body: String
}

if let commentJsonURL = getFileURL(withName: "Comments", andExtension: "json") {
    guard let commentJsonData = try? Data(contentsOf: commentJsonURL) else {
        fatalError("Could not gather data")
    }
    let jsonDecoder = JSONDecoder()
    
    guard let comments = try? jsonDecoder.decode([Comment].self, from: commentJsonData) else {
        fatalError("Could not parse data")
    }
    print("Content in [Comment] Array with enum CodingKeys:")
    print(comments)
    print("-----")
}



struct CommentsList: Codable {
    var commentList: [Comment]
}

if let commentJSONURL = getFileURL(withName: "CommentsList", andExtension: "json") {
    guard let commentJSONData = try? Data(contentsOf: commentJSONURL) else {
        fatalError("Could not gather data")
    }
    let jsonDecoder = JSONDecoder()
    
    guard let comments = try? jsonDecoder.decode(CommentsList.self, from: commentJSONData) else {
        fatalError("Could not parse data")
    }
    print("Content in commentsList Struct:")
    print(comments)
    print("-----")
}



let urlSession = URLSession.shared
guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
    fatalError("URL not valid")
}

/* Otra manera de escribir el Closure
 
 let dataTask = urlSession.dataTask(with: url, completionHandler: {
    data, response, error in
    guard let data = data else { return }
 })
 
*/

let dataTask = urlSession.dataTask(with: url) {
    data, response, error in
    guard let data = data else { return }
    let jsonDecoder = JSONDecoder()
    guard let postList = try? jsonDecoder.decode([Post].self, from: data) else { return }
    print("First element in postList array from url:")
    print(postList[0])
    print("-----")
}
dataTask.resume()
