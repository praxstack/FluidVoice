@testable import FluidVoice_Debug
import XCTest

// Regression tests for https://github.com/altic-dev/FluidVoice/issues/295
// Ollama and compatible OpenAI-format providers treat an absent `stream` key as true.
// The fix is to always send the key explicitly, whether streaming or not.

@MainActor
final class LLMClientRequestBodyTests: XCTestCase {

    private func config(streaming: Bool) -> LLMClient.Config {
        LLMClient.Config(
            messages: [["role": "user", "content": "hello"]],
            model: "llama3",
            baseURL: "http://localhost:11434/v1",
            apiKey: "",
            streaming: streaming
        )
    }

    // MARK: - Chat Completions endpoint

    func testChatCompletionsBody_streamFalse_keyIsPresentAndFalse() {
        let body = LLMClient.shared.buildChatCompletionsBody(config(streaming: false))
        XCTAssertNotNil(body["stream"], "stream key must be present when streaming=false — absent key breaks Ollama-compatible providers")
        XCTAssertEqual(body["stream"] as? Bool, false)
    }

    func testChatCompletionsBody_streamTrue_keyIsPresentAndTrue() {
        let body = LLMClient.shared.buildChatCompletionsBody(config(streaming: true))
        XCTAssertEqual(body["stream"] as? Bool, true)
    }

    // MARK: - Responses endpoint

    func testResponsesBody_streamFalse_keyIsPresentAndFalse() {
        let body = LLMClient.shared.buildResponsesBody(config(streaming: false))
        XCTAssertNotNil(body["stream"], "stream key must be present when streaming=false")
        XCTAssertEqual(body["stream"] as? Bool, false)
    }

    func testResponsesBody_streamTrue_keyIsPresentAndTrue() {
        let body = LLMClient.shared.buildResponsesBody(config(streaming: true))
        XCTAssertEqual(body["stream"] as? Bool, true)
    }
}
