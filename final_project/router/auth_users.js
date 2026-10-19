const express = require('express');
const jwt = require('jsonwebtoken');
let books = require("./booksdb.js");
const regd_users = express.Router();

let users = [];

const isValid = (username) => { // returns boolean
    // Check if username exists in the registered users list
    let userswithsamename = users.filter((user) => {
        return user.username === username;
    });
    return userswithsamename.length > 0;
};

const authenticatedUser = (username, password) => { // returns boolean
    // Check if username and password match records
    let validusers = users.filter((user) => {
        return (user.username === username && user.password === password);
    });
    return validusers.length > 0;
};

// Task 7: Only registered users can login
regd_users.post("/login", (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(404).json({ message: "Error logging in: username and password required" });
    }

    if (authenticatedUser(username, password)) {
        let accessToken = jwt.sign({
            data: password,
            username: username
        }, 'access', { expiresIn: 60 * 60 });

        req.session.authorization = {
            accessToken,
            username
        };

        return res.status(200).json({
            message: "User successfully logged in",
            token: accessToken
        });
    } else {
        return res.status(208).json({ message: "Invalid Login. Check username and password" });
    }
});

// Task 8: Add or modify a book review
regd_users.put("/auth/review/:isbn", (req, res) => {
    const isbn = req.params.isbn;
    const review = req.query.review || (req.body && req.body.review);
    const username = (req.session && req.session.authorization && req.session.authorization.username) ||
                     (req.user && (req.user.username || req.user.data));

    if (!username) {
        return res.status(403).json({ message: "Unauthorized: User not logged in" });
    }

    if (!review) {
        return res.status(400).json({ message: "Review content is required" });
    }

    if (books[isbn]) {
        if (!books[isbn].reviews) {
            books[isbn].reviews = {};
        }
        books[isbn].reviews[username] = review;
        return res.status(200).json({
            message: `The review for the book with ISBN ${isbn} has been added/updated.`
        });
    } else {
        return res.status(404).json({ message: `Book with ISBN ${isbn} not found` });
    }
});

// Task 9: Delete a book review added by that particular user
regd_users.delete("/auth/review/:isbn", (req, res) => {
    const isbn = req.params.isbn;
    const username = (req.session && req.session.authorization && req.session.authorization.username) ||
                     (req.user && (req.user.username || req.user.data));

    if (!username) {
        return res.status(403).json({ message: "Unauthorized: User not logged in" });
    }

    if (books[isbn]) {
        let bookReviews = books[isbn].reviews;
        if (bookReviews && bookReviews[username]) {
            delete bookReviews[username];
            return res.status(200).json({
                message: `Reviews for the ISBN ${isbn} posted by the user ${username} deleted.`
            });
        } else {
            return res.status(404).json({
                message: `No review found by user '${username}' for ISBN ${isbn}`
            });
        }
    } else {
        return res.status(404).json({ message: `Book with ISBN ${isbn} not found` });
    }
});

module.exports.authenticated = regd_users;
module.exports.isValid = isValid;
module.exports.users = users;

