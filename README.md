# BookStoreCore
A package that contains the entities related to Library Management App and a DataManager that manages the passing of data to and from the SQLite DB 

**Requirements**:  *ios 16+ / swift 5.7+ / XCode 14+*   

### Package URL : 
[BookStoreCore](https://zrepository.zoho.com/zohocorp/user/Sangavi/BookStoreCore.git)

###Installation: 
### Swift Package Manager:  
```
 File > Add Packages > Enter package URL > Select appropriate Dependency rules > Click on Copy dependency

```

###Usage:
``` 
    import BookStoreCore 
    import UIKit  
    class ViewController: UIViewController{ 
         override func viewDidLoad(){  
             super.viewDidLoad() 
         } 
    } 
``` 

### Data Provider:  
- This contains a globally accessible property called **"dataProvider"** which is a **shared** instance of the DataProvider and a DataProviderProtocol.  

- Here **abstraction** is introduced by means of DataProviderProtocol between the DataProvider and those that request data. 

- The DataProvider can be **DB or File** 

### DB:  
- Here **SQLite DB** is used to store and retreive data  

- This group contains DBHandling classes  

- For Each table, a separate helper class is created to manage that particular table.  

- When DB call to fetch, insert, delete, update data is unsuccessfully, it is notified by means of **error handling.**

### Model:   
- The package contains core entities that are related to a Library Management App like **Account, MemberAccount, Book, BookOrder, Library, RegisteredNotification, Review.**
 
- These classes contains properties whose value can be changed only within these classes. 

- The properties within these entities are accessible globally.

- Here **keyPath along with subscripts** are used to set and get a property. 

### Private Queues: 
- This group contains a structure called as ConcurrentQueue. 

- This structure is used to create and return a **separate concurrent DispatchQueue** solely dedicated for the purpose of handling DB related tasks. 

- All DB related tasks are added to this custom concurrent DispatchQueue so that the load on the main thread is reduced. 

### Utils: 
- This group contains two files namely DateUtils and Password Hasher 

- The DateUtils is a structure that contains static func used for date handling 

- The Password Hasher takes in emailId, password and returns a hashed string processed using SHA256 algorithm.
