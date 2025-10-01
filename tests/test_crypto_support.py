import pytest

from tradingagents.utils.stock_utils import StockUtils, StockMarket


def test_identify_crypto_market():
    assert StockUtils.identify_stock_market('BTC-USD') == StockMarket.CRYPTO
    assert StockUtils.identify_stock_market('ethusdt') == StockMarket.CRYPTO


def test_normalize_crypto_ticker():
    assert StockUtils.normalize_crypto_ticker('btc-usdt') == 'BTC-USD'
    assert StockUtils.normalize_crypto_ticker('ethusd') == 'ETH-USD'
    assert StockUtils.normalize_crypto_ticker('SOL/USDT') == 'SOL-USD'


def test_crypto_currency_info():
    name, symbol = StockUtils.get_currency_info('BTC-USD')
    assert symbol in {'$', 'USDT'}
    assert name in {'美元', '泰达币'}
