from ninja import NinjaAPI

from config.settings import BRANCH, COMMIT, TAG

api = NinjaAPI(
    title="TodoAPI",
    version=TAG,
    description=f"API version: {TAG} <br>Branch: {BRANCH} <br>Commit: {COMMIT}",
)

api.add_router("/todos/", "todos.api.router")
