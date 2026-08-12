// Shared data model for Chapter 21 (网络数据请求) network demos.
// Field names and types must match the JSON returned by the API.
export interface Post {
  userId: number
  id: number
  title: string
  body: string
}
