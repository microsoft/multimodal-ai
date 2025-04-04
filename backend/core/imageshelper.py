import base64
import logging
import os
import re
from typing import Optional

from azure.core.exceptions import ResourceNotFoundError
from azure.storage.blob.aio import ContainerClient
from typing_extensions import Literal, Required, TypedDict

from approaches.approach import Document


class ImageURL(TypedDict, total=False):
    url: Required[str]
    """Either a URL of the image or the base64 encoded image data."""

    detail: Literal["auto", "low", "high"]
    """Specifies the detail level of the image."""


async def download_blob_as_base64(blob_container_client: ContainerClient, file_path: str) -> Optional[str]:
    try:
        blob = await blob_container_client.get_blob_client(file_path).download_blob()
        if not blob.properties:
            logging.warning(f"No blob exists for {file_path}")
            return None
        img = base64.b64encode(await blob.readall()).decode("utf-8")
        return f"data:image/png;base64,{img}"
    except ResourceNotFoundError:
        logging.warning(f"No blob exists for {file_path}")
        return None


async def fetch_image(blob_container_client: ContainerClient, result: Document) -> Optional[ImageURL]:
    if result.sourcepage:
        match = re.search(r'-([0-9]+)\.', result.sourcepage)
        page_idx = match.group(1)

        file_path = f"{result.parent_id}/normalized_images_{page_idx}.jpg"
        img = await download_blob_as_base64(blob_container_client, file_path)
        if img:
            return {"url": img, "detail": "auto"}
        else:
            return None
    return None
