import 'dart:convert';

BlogEntry blogEntryFromJson(String str) => BlogEntry.fromJson(json.decode(str));

String blogEntryToJson(BlogEntry data) => json.encode(data.toJson());

class BlogEntry {
  List<Blog> blogs;

  BlogEntry({
    required this.blogs,
  });

  factory BlogEntry.fromJson(Map<String, dynamic> json) => BlogEntry(
    blogs: List<Blog>.from(json["blogs"].map((x) => Blog.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "blogs": List<dynamic>.from(blogs.map((x) => x.toJson())),
  };
}

class Blog {
  String id;
  String title;
  String summary;
  String thumbnail;
  String author;
  DateTime createdAt;
  int blogViews;
  String url;

  Blog({
    required this.id,
    required this.title,
    required this.summary,
    required this.thumbnail,
    required this.author,
    required this.createdAt,
    required this.blogViews,
    required this.url,
  });

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
    id: json["id"],
    title: json["title"],
    summary: json["summary"],
    thumbnail: json["thumbnail"],
    author: json["author"],
    createdAt: DateTime.parse(json["created_at"]),
    blogViews: json["blog_views"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "summary": summary,
    "thumbnail": thumbnail,
    "author": author,
    "created_at": createdAt.toIso8601String(),
    "blog_views": blogViews,
    "url": url,
  };
}
