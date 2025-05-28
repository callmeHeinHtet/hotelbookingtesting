class Room {
  final String id;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final List<String> amenities;
  final List<String> images;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.amenities,
    required this.images,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      capacity: json['capacity'] as int,
      amenities: List<String>.from(json['amenities'] as List),
      images: List<String>.from(json['images'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'capacity': capacity,
      'amenities': amenities,
      'images': images,
    };
  }
} 