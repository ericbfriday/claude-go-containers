# Lesson 14: API Integration & HTTP Clients

**Phase**: 2 - Building Command-Line Tools
**Estimated Time**: 4-6 hours
**Difficulty**: Intermediate
**Prerequisites**: Lessons 01-13 (especially Lesson 11-12: Cobra Framework)

## Overview

Learn to build CLI tools that interact with REST APIs using Go's `net/http` package. Master HTTP requests, JSON parsing, error handling, authentication, rate limiting, and retry logic to create robust API-powered command-line applications.

## Learning Objectives

By the end of this lesson, you will be able to:

1. Make GET, POST, PUT, and DELETE requests using `net/http`
2. Parse and marshal JSON data for API requests and responses
3. Implement proper HTTP error handling and status code validation
4. Add authentication (API keys, Bearer tokens, Basic Auth)
5. Implement rate limiting and exponential backoff retry logic
6. Build CLI tools that integrate with real-world APIs (GitHub, OpenWeather, etc.)
7. Handle API pagination and large response sets
8. Implement request timeouts and context cancellation

## Why API Integration Matters

Modern CLI tools frequently interact with web services:

- **Data Access**: Retrieve real-time information from external sources
- **Automation**: Automate workflows with third-party services
- **Integration**: Connect local tools with cloud platforms
- **Productivity**: Command-line access to web services

Tools like `gh` (GitHub CLI), `kubectl`, `aws-cli`, and `stripe` demonstrate the power of API-integrated CLIs.

## Core Concepts

### 1. HTTP Client Basics

Go's `net/http` package provides a complete HTTP client:

```go
package main

import (
	"fmt"
	"io"
	"net/http"
	"time"
)

func main() {
	// Simple GET request
	resp, err := http.Get("https://api.github.com/users/octocat")
	if err != nil {
		fmt.Printf("Request failed: %v\n", err)
		return
	}
	defer resp.Body.Close()

	// Check status code
	if resp.StatusCode != http.StatusOK {
		fmt.Printf("Unexpected status: %s\n", resp.Status)
		return
	}

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("Failed to read body: %v\n", err)
		return
	}

	fmt.Println(string(body))
}

// Better: Create configured client
func createHTTPClient() *http.Client {
	return &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			MaxIdleConns:        10,
			IdleConnTimeout:     30 * time.Second,
			DisableCompression:  false,
			DisableKeepAlives:   false,
		},
	}
}

// Reusable GET function
func doGet(client *http.Client, url string) ([]byte, error) {
	resp, err := client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("GET request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	return body, nil
}
```

**Client Configuration Options**:
- **Timeout**: Maximum time for request completion
- **MaxIdleConns**: Connection pool size
- **Transport**: Low-level HTTP settings
- **CheckRedirect**: Custom redirect handling

### 2. JSON Request and Response Handling

APIs typically communicate using JSON:

```go
package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// API data structures
type User struct {
	ID        int    `json:"id"`
	Username  string `json:"username"`
	Email     string `json:"email"`
	CreatedAt string `json:"created_at"`
}

type CreateUserRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
	Code    int    `json:"code"`
}

// GET request with JSON response
func GetUser(client *http.Client, baseURL string, userID int) (*User, error) {
	url := fmt.Sprintf("%s/users/%d", baseURL, userID)

	resp, err := client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Handle error responses
	if resp.StatusCode != http.StatusOK {
		var errResp ErrorResponse
		if err := json.Unmarshal(body, &errResp); err != nil {
			return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
		}
		return nil, fmt.Errorf("API error: %s", errResp.Message)
	}

	// Parse successful response
	var user User
	if err := json.Unmarshal(body, &user); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &user, nil
}

// POST request with JSON payload
func CreateUser(client *http.Client, baseURL string, req CreateUserRequest) (*User, error) {
	url := fmt.Sprintf("%s/users", baseURL)

	// Marshal request to JSON
	jsonData, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create POST request
	httpReq, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	httpReq.Header.Set("Content-Type", "application/json")

	// Execute request
	resp, err := client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Handle non-2xx status codes
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		var errResp ErrorResponse
		if err := json.Unmarshal(body, &errResp); err != nil {
			return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
		}
		return nil, fmt.Errorf("API error: %s", errResp.Message)
	}

	// Parse success response
	var user User
	if err := json.Unmarshal(body, &user); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &user, nil
}

// PUT and DELETE requests
func UpdateUser(client *http.Client, baseURL string, userID int, updates map[string]string) error {
	url := fmt.Sprintf("%s/users/%d", baseURL, userID)

	jsonData, err := json.Marshal(updates)
	if err != nil {
		return fmt.Errorf("failed to marshal updates: %w", err)
	}

	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	return nil
}

func DeleteUser(client *http.Client, baseURL string, userID int) error {
	url := fmt.Sprintf("%s/users/%d", baseURL, userID)

	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
	}

	return nil
}
```

### 3. Authentication Patterns

Common authentication methods for APIs:

```go
package api

import (
	"encoding/base64"
	"fmt"
	"net/http"
)

// API Key authentication
type APIKeyClient struct {
	BaseURL string
	APIKey  string
	Client  *http.Client
}

func (c *APIKeyClient) NewRequest(method, path string, body io.Reader) (*http.Request, error) {
	url := fmt.Sprintf("%s%s", c.BaseURL, path)
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}

	// API key in query parameter
	q := req.URL.Query()
	q.Add("api_key", c.APIKey)
	req.URL.RawQuery = q.Encode()

	return req, nil
}

// Bearer Token authentication
type BearerTokenClient struct {
	BaseURL string
	Token   string
	Client  *http.Client
}

func (c *BearerTokenClient) NewRequest(method, path string, body io.Reader) (*http.Request, error) {
	url := fmt.Sprintf("%s%s", c.BaseURL, path)
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}

	// Bearer token in Authorization header
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.Token))

	return req, nil
}

// Basic Authentication
type BasicAuthClient struct {
	BaseURL  string
	Username string
	Password string
	Client   *http.Client
}

func (c *BasicAuthClient) NewRequest(method, path string, body io.Reader) (*http.Request, error) {
	url := fmt.Sprintf("%s%s", c.BaseURL, path)
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}

	// Basic auth in Authorization header
	auth := c.Username + ":" + c.Password
	encoded := base64.StdEncoding.EncodeToString([]byte(auth))
	req.Header.Set("Authorization", fmt.Sprintf("Basic %s", encoded))

	return req, nil
}

// Custom header authentication
type CustomHeaderClient struct {
	BaseURL    string
	HeaderName string
	HeaderValue string
	Client     *http.Client
}

func (c *CustomHeaderClient) NewRequest(method, path string, body io.Reader) (*http.Request, error) {
	url := fmt.Sprintf("%s%s", c.BaseURL, path)
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}

	req.Header.Set(c.HeaderName, c.HeaderValue)

	return req, nil
}

// Generic API client with authentication
type APIClient struct {
	BaseURL string
	Client  *http.Client
	Auth    AuthProvider
}

type AuthProvider interface {
	AddAuth(req *http.Request) error
}

type APIKeyAuth struct {
	Key string
}

func (a *APIKeyAuth) AddAuth(req *http.Request) error {
	q := req.URL.Query()
	q.Add("api_key", a.Key)
	req.URL.RawQuery = q.Encode()
	return nil
}

type BearerTokenAuth struct {
	Token string
}

func (a *BearerTokenAuth) AddAuth(req *http.Request) error {
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", a.Token))
	return nil
}

func (c *APIClient) Do(req *http.Request) (*http.Response, error) {
	if c.Auth != nil {
		if err := c.Auth.AddAuth(req); err != nil {
			return nil, fmt.Errorf("auth failed: %w", err)
		}
	}

	return c.Client.Do(req)
}
```

### 4. Error Handling and Status Codes

Proper HTTP error handling:

```go
package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// APIError represents an API error response
type APIError struct {
	StatusCode int
	Status     string
	Message    string
	Details    map[string]interface{}
}

func (e *APIError) Error() string {
	if e.Message != "" {
		return fmt.Sprintf("API error (%d %s): %s", e.StatusCode, e.Status, e.Message)
	}
	return fmt.Sprintf("API error: %d %s", e.StatusCode, e.Status)
}

// CheckResponse validates HTTP response and returns typed errors
func CheckResponse(resp *http.Response) error {
	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		return nil
	}

	apiErr := &APIError{
		StatusCode: resp.StatusCode,
		Status:     resp.Status,
	}

	// Try to parse error response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return apiErr
	}

	// Try to unmarshal as JSON error
	var errResp struct {
		Error   string                 `json:"error"`
		Message string                 `json:"message"`
		Details map[string]interface{} `json:"details"`
	}

	if err := json.Unmarshal(body, &errResp); err == nil {
		apiErr.Message = errResp.Message
		if apiErr.Message == "" {
			apiErr.Message = errResp.Error
		}
		apiErr.Details = errResp.Details
	} else {
		// Fallback to raw body
		apiErr.Message = string(body)
	}

	return apiErr
}

// Handle specific status codes
func HandleResponse(resp *http.Response) error {
	switch resp.StatusCode {
	case http.StatusOK, http.StatusCreated, http.StatusNoContent:
		return nil

	case http.StatusBadRequest:
		return fmt.Errorf("bad request: check your input parameters")

	case http.StatusUnauthorized:
		return fmt.Errorf("unauthorized: check your API credentials")

	case http.StatusForbidden:
		return fmt.Errorf("forbidden: insufficient permissions")

	case http.StatusNotFound:
		return fmt.Errorf("not found: the requested resource does not exist")

	case http.StatusTooManyRequests:
		return fmt.Errorf("rate limit exceeded: please retry later")

	case http.StatusInternalServerError:
		return fmt.Errorf("server error: please try again later")

	case http.StatusServiceUnavailable:
		return fmt.Errorf("service unavailable: the API is temporarily down")

	default:
		return CheckResponse(resp)
	}
}

// Example usage
func GetResource(client *http.Client, url string) ([]byte, error) {
	resp, err := client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if err := HandleResponse(resp); err != nil {
		return nil, err
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	return body, nil
}
```

### 5. Rate Limiting and Retry Logic

Implement exponential backoff for resilient API calls:

```go
package api

import (
	"fmt"
	"math"
	"net/http"
	"time"
)

// RateLimiter manages API request rate limits
type RateLimiter struct {
	requestsPerSecond int
	lastRequest       time.Time
}

func NewRateLimiter(requestsPerSecond int) *RateLimiter {
	return &RateLimiter{
		requestsPerSecond: requestsPerSecond,
		lastRequest:       time.Time{},
	}
}

func (rl *RateLimiter) Wait() {
	if rl.requestsPerSecond <= 0 {
		return
	}

	minInterval := time.Second / time.Duration(rl.requestsPerSecond)
	elapsed := time.Since(rl.lastRequest)

	if elapsed < minInterval {
		time.Sleep(minInterval - elapsed)
	}

	rl.lastRequest = time.Now()
}

// RetryConfig configures retry behavior
type RetryConfig struct {
	MaxRetries  int
	InitialWait time.Duration
	MaxWait     time.Duration
	Multiplier  float64
}

func DefaultRetryConfig() RetryConfig {
	return RetryConfig{
		MaxRetries:  3,
		InitialWait: 1 * time.Second,
		MaxWait:     30 * time.Second,
		Multiplier:  2.0,
	}
}

// RetryableRequest executes HTTP request with exponential backoff
func RetryableRequest(
	client *http.Client,
	req *http.Request,
	config RetryConfig,
) (*http.Response, error) {
	var resp *http.Response
	var err error

	for attempt := 0; attempt <= config.MaxRetries; attempt++ {
		if attempt > 0 {
			// Calculate exponential backoff
			wait := time.Duration(float64(config.InitialWait) *
				math.Pow(config.Multiplier, float64(attempt-1)))

			if wait > config.MaxWait {
				wait = config.MaxWait
			}

			fmt.Printf("Retry attempt %d after %v\n", attempt, wait)
			time.Sleep(wait)
		}

		resp, err = client.Do(req)
		if err != nil {
			// Network error - retry
			continue
		}

		// Retry on 5xx errors and 429 (rate limit)
		if resp.StatusCode >= 500 || resp.StatusCode == http.StatusTooManyRequests {
			resp.Body.Close()
			continue
		}

		// Success or non-retryable error
		return resp, nil
	}

	if err != nil {
		return nil, fmt.Errorf("request failed after %d retries: %w", config.MaxRetries, err)
	}

	return resp, fmt.Errorf("request failed after %d retries: HTTP %d", config.MaxRetries, resp.StatusCode)
}

// API client with rate limiting and retries
type ResilientAPIClient struct {
	BaseURL     string
	Client      *http.Client
	RateLimiter *RateLimiter
	RetryConfig RetryConfig
}

func NewResilientAPIClient(baseURL string, requestsPerSecond int) *ResilientAPIClient {
	return &ResilientAPIClient{
		BaseURL: baseURL,
		Client: &http.Client{
			Timeout: 30 * time.Second,
		},
		RateLimiter: NewRateLimiter(requestsPerSecond),
		RetryConfig: DefaultRetryConfig(),
	}
}

func (c *ResilientAPIClient) Do(req *http.Request) (*http.Response, error) {
	// Apply rate limiting
	c.RateLimiter.Wait()

	// Execute with retries
	return RetryableRequest(c.Client, req, c.RetryConfig)
}

// Example: GitHub API with rate limiting
type GitHubClient struct {
	*ResilientAPIClient
	Token string
}

func NewGitHubClient(token string) *GitHubClient {
	return &GitHubClient{
		ResilientAPIClient: NewResilientAPIClient("https://api.github.com", 5),
		Token:              token,
	}
}

func (c *GitHubClient) GetUser(username string) (map[string]interface{}, error) {
	url := fmt.Sprintf("%s/users/%s", c.BaseURL, username)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	if c.Token != "" {
		req.Header.Set("Authorization", fmt.Sprintf("token %s", c.Token))
	}
	req.Header.Set("Accept", "application/vnd.github.v3+json")

	resp, err := c.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if err := CheckResponse(resp); err != nil {
		return nil, err
	}

	var user map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return user, nil
}
```

### 6. Pagination Handling

Handle paginated API responses:

```go
package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
)

// PaginatedResponse represents a paginated API response
type PaginatedResponse struct {
	Data       []interface{} `json:"data"`
	Page       int           `json:"page"`
	PerPage    int           `json:"per_page"`
	Total      int           `json:"total"`
	TotalPages int           `json:"total_pages"`
	NextPage   *string       `json:"next_page"`
}

// PageIterator provides iteration over paginated results
type PageIterator struct {
	client  *http.Client
	baseURL string
	nextURL *string
	auth    AuthProvider
}

func NewPageIterator(client *http.Client, baseURL string, auth AuthProvider) *PageIterator {
	return &PageIterator{
		client:  client,
		baseURL: baseURL,
		nextURL: &baseURL,
		auth:    auth,
	}
}

func (p *PageIterator) HasNext() bool {
	return p.nextURL != nil
}

func (p *PageIterator) Next() (*PaginatedResponse, error) {
	if !p.HasNext() {
		return nil, fmt.Errorf("no more pages")
	}

	req, err := http.NewRequest("GET", *p.nextURL, nil)
	if err != nil {
		return nil, err
	}

	if p.auth != nil {
		if err := p.auth.AddAuth(req); err != nil {
			return nil, err
		}
	}

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if err := CheckResponse(resp); err != nil {
		return nil, err
	}

	var pageResp PaginatedResponse
	if err := json.NewDecoder(resp.Body).Decode(&pageResp); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	// Update next page URL
	p.nextURL = pageResp.NextPage

	return &pageResp, nil
}

// FetchAllPages retrieves all pages of results
func FetchAllPages(
	client *http.Client,
	baseURL string,
	auth AuthProvider,
	maxPages int,
) ([]interface{}, error) {
	var allData []interface{}
	iterator := NewPageIterator(client, baseURL, auth)
	pageCount := 0

	for iterator.HasNext() {
		if maxPages > 0 && pageCount >= maxPages {
			break
		}

		page, err := iterator.Next()
		if err != nil {
			return allData, fmt.Errorf("failed to fetch page %d: %w", pageCount+1, err)
		}

		allData = append(allData, page.Data...)
		pageCount++

		fmt.Printf("Fetched page %d of %d (%d items)\n",
			page.Page, page.TotalPages, len(page.Data))
	}

	return allData, nil
}

// Cursor-based pagination (common in APIs like GitHub)
type CursorPagination struct {
	client  *http.Client
	baseURL string
	cursor  *string
	auth    AuthProvider
}

func NewCursorPagination(client *http.Client, baseURL string, auth AuthProvider) *CursorPagination {
	return &CursorPagination{
		client:  client,
		baseURL: baseURL,
		auth:    auth,
	}
}

func (c *CursorPagination) FetchPage(perPage int) ([]interface{}, string, error) {
	u, err := url.Parse(c.baseURL)
	if err != nil {
		return nil, "", err
	}

	q := u.Query()
	q.Set("per_page", strconv.Itoa(perPage))
	if c.cursor != nil {
		q.Set("cursor", *c.cursor)
	}
	u.RawQuery = q.Encode()

	req, err := http.NewRequest("GET", u.String(), nil)
	if err != nil {
		return nil, "", err
	}

	if c.auth != nil {
		c.auth.AddAuth(req)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, "", err
	}
	defer resp.Body.Close()

	if err := CheckResponse(resp); err != nil {
		return nil, "", err
	}

	var result struct {
		Data       []interface{} `json:"data"`
		NextCursor string        `json:"next_cursor"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, "", err
	}

	return result.Data, result.NextCursor, nil
}
```

### 7. Context and Timeouts

Use context for cancellation and timeouts:

```go
package api

import (
	"context"
	"fmt"
	"net/http"
	"time"
)

// DoWithContext executes request with context
func DoWithContext(ctx context.Context, client *http.Client, req *http.Request) (*http.Response, error) {
	req = req.WithContext(ctx)
	return client.Do(req)
}

// GetWithTimeout performs GET request with timeout
func GetWithTimeout(client *http.Client, url string, timeout time.Duration) (*http.Response, error) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}

	return client.Do(req)
}

// Example: Cancelable API operation
func FetchDataCancelable(ctx context.Context, client *http.Client, urls []string) ([][]byte, error) {
	results := make([][]byte, 0, len(urls))

	for i, url := range urls {
		select {
		case <-ctx.Done():
			return results, ctx.Err()
		default:
		}

		fmt.Printf("Fetching %d/%d: %s\n", i+1, len(urls), url)

		req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
		if err != nil {
			return results, err
		}

		resp, err := client.Do(req)
		if err != nil {
			return results, err
		}

		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			return results, err
		}

		results = append(results, body)
	}

	return results, nil
}

// Parallel requests with context
func FetchParallel(ctx context.Context, client *http.Client, urls []string) (map[string][]byte, error) {
	results := make(map[string][]byte)
	errChan := make(chan error, len(urls))
	resultChan := make(chan struct {
		url  string
		data []byte
	}, len(urls))

	// Start goroutines for each URL
	for _, url := range urls {
		go func(u string) {
			req, err := http.NewRequestWithContext(ctx, "GET", u, nil)
			if err != nil {
				errChan <- err
				return
			}

			resp, err := client.Do(req)
			if err != nil {
				errChan <- err
				return
			}
			defer resp.Body.Close()

			body, err := io.ReadAll(resp.Body)
			if err != nil {
				errChan <- err
				return
			}

			resultChan <- struct {
				url  string
				data []byte
			}{u, body}
		}(url)
	}

	// Collect results
	for i := 0; i < len(urls); i++ {
		select {
		case <-ctx.Done():
			return results, ctx.Err()
		case err := <-errChan:
			return results, err
		case result := <-resultChan:
			results[result.url] = result.data
		}
	}

	return results, nil
}
```

### 8. Real-World API Examples

Complete implementations for popular APIs:

```go
// GitHub API Client
package github

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type Client struct {
	baseURL string
	token   string
	client  *http.Client
}

func NewClient(token string) *Client {
	return &Client{
		baseURL: "https://api.github.com",
		token:   token,
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

type Repository struct {
	Name        string `json:"name"`
	FullName    string `json:"full_name"`
	Description string `json:"description"`
	URL         string `json:"html_url"`
	Stars       int    `json:"stargazers_count"`
	Forks       int    `json:"forks_count"`
	Language    string `json:"language"`
}

func (c *Client) GetUserRepos(username string) ([]Repository, error) {
	url := fmt.Sprintf("%s/users/%s/repos", c.baseURL, username)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Accept", "application/vnd.github.v3+json")
	if c.token != "" {
		req.Header.Set("Authorization", fmt.Sprintf("token %s", c.token))
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, resp.Status)
	}

	var repos []Repository
	if err := json.NewDecoder(resp.Body).Decode(&repos); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return repos, nil
}

// OpenWeatherMap API Client
package weather

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"
)

type Client struct {
	baseURL string
	apiKey  string
	client  *http.Client
}

func NewClient(apiKey string) *Client {
	return &Client{
		baseURL: "https://api.openweathermap.org/data/2.5",
		apiKey:  apiKey,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

type Weather struct {
	Location    string  `json:"name"`
	Temperature float64 `json:"temp"`
	Feels       Like float64 `json:"feels_like"`
	Description string  `json:"description"`
	Humidity    int     `json:"humidity"`
	WindSpeed   float64 `json:"wind_speed"`
}

func (c *Client) GetCurrentWeather(city string) (*Weather, error) {
	u, _ := url.Parse(fmt.Sprintf("%s/weather", c.baseURL))
	q := u.Query()
	q.Set("q", city)
	q.Set("appid", c.apiKey)
	q.Set("units", "metric")
	u.RawQuery = q.Encode()

	resp, err := c.client.Get(u.String())
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP %d: city not found or API error", resp.StatusCode)
	}

	var result struct {
		Name string `json:"name"`
		Main struct {
			Temp      float64 `json:"temp"`
			FeelsLike float64 `json:"feels_like"`
			Humidity  int     `json:"humidity"`
		} `json:"main"`
		Weather []struct {
			Description string `json:"description"`
		} `json:"weather"`
		Wind struct {
			Speed float64 `json:"speed"`
		} `json:"wind"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	weather := &Weather{
		Location:    result.Name,
		Temperature: result.Main.Temp,
		FeelsLike:   result.Main.FeelsLike,
		Humidity:    result.Main.Humidity,
		WindSpeed:   result.Wind.Speed,
	}

	if len(result.Weather) > 0 {
		weather.Description = result.Weather[0].Description
	}

	return weather, nil
}
```

## Practical Examples

### Example 1: GitHub User Activity CLI

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/spf13/cobra"
)

type Event struct {
	Type      string    `json:"type"`
	Repo      RepoInfo  `json:"repo"`
	CreatedAt time.Time `json:"created_at"`
}

type RepoInfo struct {
	Name string `json:"name"`
}

func main() {
	var username string
	var token string

	rootCmd := &cobra.Command{
		Use:   "ghactivity",
		Short: "View GitHub user activity",
	}

	activityCmd := &cobra.Command{
		Use:   "show [username]",
		Short: "Show recent activity for a user",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			username = args[0]
			return showActivity(username, token)
		},
	}

	activityCmd.Flags().StringVarP(&token, "token", "t", "", "GitHub personal access token")

	rootCmd.AddCommand(activityCmd)
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func showActivity(username, token string) error {
	url := fmt.Sprintf("https://api.github.com/users/%s/events", username)

	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return err
	}

	req.Header.Set("Accept", "application/vnd.github.v3+json")
	if token != "" {
		req.Header.Set("Authorization", fmt.Sprintf("token %s", token))
	}

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTP %d: failed to fetch activity", resp.StatusCode)
	}

	var events []Event
	if err := json.NewDecoder(resp.Body).Decode(&events); err != nil {
		return fmt.Errorf("failed to parse response: %w", err)
	}

	fmt.Printf("Recent activity for %s:\n\n", username)
	for _, event := range events[:min(10, len(events))] {
		fmt.Printf("[%s] %s - %s\n",
			event.CreatedAt.Format("2006-01-02 15:04"),
			event.Type,
			event.Repo.Name)
	}

	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
```

### Example 2: Weather CLI with Caching

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"time"

	"github.com/spf13/cobra"
)

type WeatherData struct {
	Location    string
	Temperature float64
	Description string
	Humidity    int
	CachedAt    time.Time
}

var cache = make(map[string]WeatherData)

func main() {
	var apiKey string
	var units string

	rootCmd := &cobra.Command{
		Use:   "weather",
		Short: "Get weather information",
	}

	currentCmd := &cobra.Command{
		Use:   "current [city]",
		Short: "Get current weather",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			city := args[0]

			// Check cache (5-minute expiry)
			if cached, ok := cache[city]; ok {
				if time.Since(cached.CachedAt) < 5*time.Minute {
					fmt.Println("(cached)")
					displayWeather(cached)
					return nil
				}
			}

			// Fetch from API
			weather, err := fetchWeather(city, apiKey, units)
			if err != nil {
				return err
			}

			// Update cache
			cache[city] = *weather

			displayWeather(*weather)
			return nil
		},
	}

	currentCmd.Flags().StringVarP(&apiKey, "api-key", "k", os.Getenv("OPENWEATHER_API_KEY"), "OpenWeatherMap API key")
	currentCmd.Flags().StringVarP(&units, "units", "u", "metric", "Units (metric/imperial)")

	rootCmd.AddCommand(currentCmd)
	rootCmd.Execute()
}

func fetchWeather(city, apiKey, units string) (*WeatherData, error) {
	baseURL := "https://api.openweathermap.org/data/2.5/weather"

	u, _ := url.Parse(baseURL)
	q := u.Query()
	q.Set("q", city)
	q.Set("appid", apiKey)
	q.Set("units", units)
	u.RawQuery = q.Encode()

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(u.String())
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP %d: check API key and city name", resp.StatusCode)
	}

	var result struct {
		Name string `json:"name"`
		Main struct {
			Temp     float64 `json:"temp"`
			Humidity int     `json:"humidity"`
		} `json:"main"`
		Weather []struct {
			Description string `json:"description"`
		} `json:"weather"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	weather := &WeatherData{
		Location:    result.Name,
		Temperature: result.Main.Temp,
		Humidity:    result.Main.Humidity,
		CachedAt:    time.Now(),
	}

	if len(result.Weather) > 0 {
		weather.Description = result.Weather[0].Description
	}

	return weather, nil
}

func displayWeather(w WeatherData) {
	fmt.Printf("\nWeather in %s:\n", w.Location)
	fmt.Printf("Temperature: %.1f°C\n", w.Temperature)
	fmt.Printf("Conditions: %s\n", w.Description)
	fmt.Printf("Humidity: %d%%\n", w.Humidity)
}
```

## Practice Challenges

### Challenge 1: GitHub User Activity CLI

**Objective**: Build a CLI that displays GitHub user activity.

**Requirements**:
1. Command: `ghactivity show [username]`
2. Fetch recent events from GitHub API
3. Display event types and timestamps
4. Support authentication via token flag
5. Handle rate limiting gracefully
6. Add `--limit` flag for number of events

**Test Requirements**:
```go
func TestGitHubActivity(t *testing.T) {
	tests := []struct {
		name       string
		username   string
		token      string
		wantErr    bool
		validate   func(*testing.T, []Event)
	}{
		{
			name:     "valid user returns events",
			username: "octocat",
			wantErr:  false,
			validate: func(t *testing.T, events []Event) {
				if len(events) == 0 {
					t.Error("should return events for valid user")
				}
			},
		},
		{
			name:     "invalid user returns error",
			username: "nonexistentuser9999999",
			wantErr:  true,
		},
		{
			name:     "with authentication token",
			username: "octocat",
			token:    os.Getenv("GITHUB_TOKEN"),
			wantErr:  false,
			validate: func(t *testing.T, events []Event) {
				// Should have higher rate limit with token
				if len(events) == 0 {
					t.Error("authenticated request should succeed")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test implementation
		})
	}
}
```

### Challenge 2: Weather CLI Tool

**Objective**: Create a weather CLI with multiple data sources.

**Requirements**:
1. Commands: `weather current [city]`, `weather forecast [city]`
2. Use OpenWeatherMap API
3. Implement response caching (5-minute TTL)
4. Support both metric and imperial units
5. Handle API errors gracefully
6. Add colored output for temperatures

**Test Requirements**:
```go
func TestWeatherCLI(t *testing.T) {
	tests := []struct {
		name      string
		city      string
		units     string
		useCache  bool
		wantErr   bool
		validate  func(*testing.T, *WeatherData)
	}{
		{
			name:    "fetch current weather",
			city:    "London",
			units:   "metric",
			wantErr: false,
			validate: func(t *testing.T, w *WeatherData) {
				if w.Location != "London" {
					t.Error("should return correct location")
				}
				if w.Temperature == 0 {
					t.Error("should return temperature data")
				}
			},
		},
		{
			name:    "invalid city returns error",
			city:    "InvalidCityName12345",
			wantErr: true,
		},
		{
			name:     "cache returns data within TTL",
			city:     "London",
			useCache: true,
			wantErr:  false,
			validate: func(t *testing.T, w *WeatherData) {
				if time.Since(w.CachedAt) > 5*time.Minute {
					t.Error("cache should be fresh")
				}
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test implementation
		})
	}
}
```

### Challenge 3: Currency Converter CLI

**Objective**: Build a CLI for currency conversion using exchange rate API.

**Requirements**:
1. Command: `currency convert [amount] [from] [to]`
2. Use ExchangeRate-API or similar service
3. Implement retry logic for failed requests
4. Cache exchange rates for 1 hour
5. Support multiple currencies
6. Add `--list` command to show available currencies

**Test Requirements**:
```go
func TestCurrencyConverter(t *testing.T) {
	tests := []struct {
		name     string
		amount   float64
		from     string
		to       string
		wantErr  bool
		validate func(*testing.T, float64)
	}{
		{
			name:    "convert USD to EUR",
			amount:  100,
			from:    "USD",
			to:      "EUR",
			wantErr: false,
			validate: func(t *testing.T, result float64) {
				if result <= 0 {
					t.Error("conversion should return positive amount")
				}
			},
		},
		{
			name:    "invalid currency code",
			amount:  100,
			from:    "INVALID",
			to:      "USD",
			wantErr: true,
		},
		{
			name:    "negative amount",
			amount:  -100,
			from:    "USD",
			to:      "EUR",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test implementation
		})
	}
}
```

## Common Pitfalls

### 1. Not Closing Response Bodies

**❌ Wrong**:
```go
resp, err := http.Get(url)
if err != nil {
	return err
}
// Missing: defer resp.Body.Close()

body, _ := io.ReadAll(resp.Body)
// Resource leak!
```

**✅ Correct**:
```go
resp, err := http.Get(url)
if err != nil {
	return err
}
defer resp.Body.Close() // Always close

body, err := io.ReadAll(resp.Body)
```

### 2. Ignoring HTTP Status Codes

**❌ Wrong**:
```go
resp, _ := http.Get(url)
defer resp.Body.Close()

var data MyStruct
json.NewDecoder(resp.Body).Decode(&data)
// Assumes success!
```

**✅ Correct**:
```go
resp, err := http.Get(url)
if err != nil {
	return err
}
defer resp.Body.Close()

if resp.StatusCode != http.StatusOK {
	return fmt.Errorf("HTTP %d: %s", resp.StatusCode, resp.Status)
}

var data MyStruct
if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
	return fmt.Errorf("failed to parse: %w", err)
}
```

### 3. No Request Timeouts

**❌ Wrong**:
```go
// Default client has no timeout
resp, err := http.Get(url)
// Can hang indefinitely
```

**✅ Correct**:
```go
client := &http.Client{
	Timeout: 30 * time.Second,
}
resp, err := client.Get(url)
```

### 4. Missing Authentication

**❌ Wrong**:
```go
// Sending requests without auth
resp, _ := http.Get("https://api.example.com/private/data")
// Returns 401 Unauthorized
```

**✅ Correct**:
```go
req, _ := http.NewRequest("GET", "https://api.example.com/private/data", nil)
req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))

resp, err := client.Do(req)
```

### 5. Not Handling Rate Limits

**❌ Wrong**:
```go
for _, user := range users {
	// Rapid-fire requests
	resp, _ := http.Get(fmt.Sprintf("/api/users/%s", user))
	// Gets rate limited
}
```

**✅ Correct**:
```go
rateLimiter := NewRateLimiter(5) // 5 requests per second

for _, user := range users {
	rateLimiter.Wait()
	resp, err := http.Get(fmt.Sprintf("/api/users/%s", user))
	// Respects rate limits
}
```

### 6. Poor Error Messages

**❌ Wrong**:
```go
if resp.StatusCode != 200 {
	return fmt.Errorf("error")
	// Unhelpful!
}
```

**✅ Correct**:
```go
if resp.StatusCode != http.StatusOK {
	body, _ := io.ReadAll(resp.Body)
	return fmt.Errorf("HTTP %d: %s - %s",
		resp.StatusCode, resp.Status, string(body))
}
```

## Extension Challenges

### 1. GraphQL API Client

Implement a GraphQL client:
- Support GraphQL queries and mutations
- Handle variables and fragments
- Implement query batching
- Add query caching

### 2. WebSocket Support

Add WebSocket functionality:
- Connect to WebSocket endpoints
- Handle real-time data streams
- Implement reconnection logic
- Support bidirectional communication

### 3. OAuth2 Flow

Implement OAuth2 authentication:
- Authorization code flow
- Token refresh logic
- Token storage and retrieval
- Device code flow for CLIs

### 4. Request Middleware

Build middleware system:
- Logging middleware
- Metrics collection
- Request signing
- Response transformation

### 5. API Mocking for Tests

Create API mock server:
- Mock common API responses
- Simulate error conditions
- Test retry logic
- Validate request format

## Learning Resources

### Official Documentation
- [net/http Package](https://pkg.go.dev/net/http)
- [encoding/json Package](https://pkg.go.dev/encoding/json)
- [context Package](https://pkg.go.dev/context)

### API Documentation
- [GitHub API v3](https://docs.github.com/en/rest)
- [OpenWeatherMap API](https://openweathermap.org/api)
- [JSONPlaceholder (testing)](https://jsonplaceholder.typicode.com/)

### Tutorials and Articles
- "Building HTTP Clients in Go" - Best practices
- "Handling API Errors" - Error handling patterns
- "Rate Limiting Strategies" - Client-side rate limiting

### Related Libraries
- [Resty](https://github.com/go-resty/resty) - HTTP client library
- [Colly](https://github.com/gocolly/colly) - Web scraping
- [Viper](https://github.com/spf13/viper) - Config management

## Summary

You've learned to build API-powered CLI tools:

**Key Achievements**:
- ✅ Make HTTP requests (GET, POST, PUT, DELETE)
- ✅ Parse JSON responses and marshal requests
- ✅ Implement authentication (API keys, tokens)
- ✅ Handle errors and status codes properly
- ✅ Add rate limiting and retry logic
- ✅ Handle pagination effectively
- ✅ Use context for timeouts and cancellation
- ✅ Build production-ready API clients

**API integration enables**:
- Real-time data access in CLIs
- Automation of web service workflows
- Integration with cloud platforms
- Command-line access to web APIs

**Next Steps**:
- Complete the Phase 2 milestone: Task Tracker CLI
- Explore Phase 3: Web Development Fundamentals

## Navigation

**Previous**: [Lesson 13: Milestone - Task Tracker CLI](lesson-13-task-tracker.md)
**Next**: [Phase 3: Web Development Fundamentals](../README.md#phase-3)
**Phase Overview**: [Phase 2: Building Command-Line Tools](../README.md#phase-2)
