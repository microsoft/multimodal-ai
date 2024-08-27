import logging
from typing import Generator
from .page import SplitPage
from .parser import Parser
from .textsplitter import TextSplitter


class Processor:

    def __init__(self, file_parser: Parser, file_splitter: TextSplitter):
        self.file_parser = file_parser
        self.file_splitter = file_splitter
                

    async def process(self, url) -> Generator[SplitPage, None, None]:
        logging.info(f'Processing file: {url}')
        pages = [page async for page in self.file_parser.parse(url)]
        split_pages = self.file_splitter.split_pages(pages)
        logging.info(f'Finished proccessing file: {url}')
        return split_pages
