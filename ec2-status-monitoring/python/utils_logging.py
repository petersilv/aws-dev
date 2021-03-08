# Import Packages -----------------------------------------------------------------------------------------------------
import logging

# Logging Config ------------------------------------------------------------------------------------------------------
def config():
    root = logging.getLogger()

    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s', 
    )