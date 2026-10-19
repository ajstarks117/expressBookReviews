const express = require('express');
const axios = require('axios');
let books = require("./booksdb.js");
let isValid = require("./auth_users.js").isValid;
let users = require("./auth_users.js").users;
const public_users = express.Router();

const BASE_URL = 'http://localhost:5000';

// Task 6: Register a new user
public_users.post("/register", (req, res) => {
    const { username, password } = req.body;

    if (username && password) {
        if (!isValid(username)) {
            users.push({ username, password });
            return res.status(200).json({ message: "Customer successfully registered. Now you can login" });
        } else {
            return res.status(404).json({ message: "User already exists!" });
        }
    }
    return res.status(404).json({ message: "Unable to register user." });
});

// Task 1 & Task 10: Get the book list available in the shop
// Implemented as an asynchronous handler using Promises and async/await
public_users.get('/', async function (req, res) {
    try {
        const getBooksList = () => {
            return new Promise((resolve, reject) => {
                if (books) {
                    resolve(books);
                } else {
                    reject({ status: 500, message: "Unable to retrieve book catalog" });
                }
            });
        };

        const bookCatalog = await getBooksList();
        return res.status(200).send(JSON.stringify(bookCatalog, null, 4));
    } catch (error) {
        return res.status(error.status || 500).json({ message: error.message || "Internal server error" });
    }
});

// Task 2 & Task 11: Get book details based on ISBN
// Implemented using Promise callbacks (.then / .catch)
public_users.get('/isbn/:isbn', function (req, res) {
    const isbn = req.params.isbn;

    const findBookByISBN = (id) => {
        return new Promise((resolve, reject) => {
            if (books[id]) {
                resolve(books[id]);
            } else {
                reject({ status: 404, message: `Book with ISBN ${id} not found` });
            }
        });
    };

    findBookByISBN(isbn)
        .then((book) => {
            return res.status(200).json(book);
        })
        .catch((error) => {
            return res.status(error.status || 500).json({ message: error.message });
        });
});
  
// Task 3 & Task 12: Get book details based on author
// Implemented as an asynchronous handler using Promises and async/await
public_users.get('/author/:author', async function (req, res) {
    const authorParam = req.params.author.toLowerCase();

    const findBooksByAuthor = (authorName) => {
        return new Promise((resolve, reject) => {
            let matchedBooks = [];
            const keys = Object.keys(books);

            keys.forEach((key) => {
                if (books[key].author.toLowerCase() === authorName) {
                    matchedBooks.push({
                        isbn: key,
                        title: books[key].title,
                        reviews: books[key].reviews
                    });
                }
            });

            if (matchedBooks.length > 0) {
                resolve(matchedBooks);
            } else {
                reject({ status: 404, message: `No books found for author '${req.params.author}'` });
            }
        });
    };

    try {
        const matchingBooks = await findBooksByAuthor(authorParam);
        return res.status(200).json({ booksbyauthor: matchingBooks });
    } catch (error) {
        return res.status(error.status || 500).json({ message: error.message });
    }
});

// Task 4 & Task 13: Get all books based on title
// Implemented as an asynchronous handler using Promises and async/await
public_users.get('/title/:title', async function (req, res) {
    const titleParam = req.params.title.toLowerCase();

    const findBooksByTitle = (bookTitle) => {
        return new Promise((resolve, reject) => {
            let matchedBooks = [];
            const keys = Object.keys(books);

            keys.forEach((key) => {
                if (books[key].title.toLowerCase() === bookTitle) {
                    matchedBooks.push({
                        isbn: key,
                        author: books[key].author,
                        reviews: books[key].reviews
                    });
                }
            });

            if (matchedBooks.length > 0) {
                resolve(matchedBooks);
            } else {
                reject({ status: 404, message: `No books found with title '${req.params.title}'` });
            }
        });
    };

    try {
        const matchingBooks = await findBooksByTitle(titleParam);
        return res.status(200).json({ booksbytitle: matchingBooks });
    } catch (error) {
        return res.status(error.status || 500).json({ message: error.message });
    }
});

// Task 5: Get book review
public_users.get('/review/:isbn', function (req, res) {
    const isbn = req.params.isbn;
    if (books[isbn]) {
        return res.status(200).json(books[isbn].reviews);
    }
    return res.status(404).json({ message: `Book with ISBN ${isbn} not found` });
});

// ============================================================================
// Tasks 10-13: Node.js client functions using Axios and Promises / Async-Await
// ============================================================================

// Task 10: Get all books available in the shop using async/await with Axios
async function getBooksAxiosAsync() {
    try {
        const response = await axios.get(`${BASE_URL}/`);
        return response.data;
    } catch (error) {
        throw error.response ? error.response.data : error;
    }
}

// Task 11: Get book details based on ISBN using Axios with Promises (.then / .catch)
function getBookByISBNAxiosPromise(isbn) {
    return axios.get(`${BASE_URL}/isbn/${isbn}`)
        .then((response) => response.data)
        .catch((error) => {
            throw error.response ? error.response.data : error;
        });
}

// Task 12: Get book details based on Author using async/await with Axios
async function getBooksByAuthorAxiosAsync(author) {
    try {
        const response = await axios.get(`${BASE_URL}/author/${encodeURIComponent(author)}`);
        return response.data;
    } catch (error) {
        throw error.response ? error.response.data : error;
    }
}

// Task 13: Get book details based on Title using async/await with Axios
async function getBooksByTitleAxiosAsync(title) {
    try {
        const response = await axios.get(`${BASE_URL}/title/${encodeURIComponent(title)}`);
        return response.data;
    } catch (error) {
        throw error.response ? error.response.data : error;
    }
}

module.exports.general = public_users;
module.exports.getBooksAxiosAsync = getBooksAxiosAsync;
module.exports.getBookByISBNAxiosPromise = getBookByISBNAxiosPromise;
module.exports.getBooksByAuthorAxiosAsync = getBooksByAuthorAxiosAsync;
module.exports.getBooksByTitleAxiosAsync = getBooksByTitleAxiosAsync;

