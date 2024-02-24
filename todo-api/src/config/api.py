from ninja import NinjaAPI

api = NinjaAPI(title="TodoAPI")

api.add_router("/todos/", "todos.api.router")
