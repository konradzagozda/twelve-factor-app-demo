from collections import namedtuple

ErrorDetails = namedtuple("ErrorDetails", ["type", "title", "detail"])
NOT_FOUND = ErrorDetails(type="ENTITY_NOT_FOUND", title="{} was not found", detail="{} with ID {} was not found.")
