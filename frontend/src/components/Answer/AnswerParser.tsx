import { renderToStaticMarkup } from "react-dom/server";
import { getCitationFilePath } from "../../api";

type Citation = {
    text: string;
    filePath: string;
};

type HtmlParsedAnswer = {
    answerHtml: string;
    citations: Citation[];
};

export function parseAnswerToHtml(answer: string, data_points: any, isStreaming: boolean, onCitationClicked: (citationFilePath: string) => void): HtmlParsedAnswer {
    const citations: Citation[] = [];

    // trim any whitespace from the end of the answer after removing follow-up questions
    let parsedAnswer = answer.trim();

    // Omit a citation that is still being typed during streaming
    if (isStreaming) {
        let lastIndex = parsedAnswer.length;
        for (let i = parsedAnswer.length - 1; i >= 0; i--) {
            if (parsedAnswer[i] === "]") {
                break;
            } else if (parsedAnswer[i] === "[") {
                lastIndex = i;
                break;
            }
        }
        const truncatedAnswer = parsedAnswer.substring(0, lastIndex);
        parsedAnswer = truncatedAnswer;
    }

    const parts = parsedAnswer.split(/\[([^\]]+)\]/g);

    const fragments: string[] = parts.map((part, index) => {
        if (index % 2 === 0) {
            return part;
        } else {
            let citationIndex: number;
            let path = getCitationFilePath(part);

            if (citations.findIndex(citation => citation.text === part) !== -1) {
                citationIndex = citations.findIndex(citation => citation.text === part) + 1;
            } else {
                const parentIds: Record<string, string> = !Array.isArray(data_points) && data_points?.parent_ids ? data_points.parent_ids : {};

                if(parentIds && part.endsWith(".jpg")){
                    const match = part.match(/-([0-9]+)\./);
                    if (match) {
                        const page_idx = match[1];
                        const parent_id = parentIds[part];
                    
                        path = getCitationFilePath(`${parent_id}/normalized_images_${page_idx}.jpg`);
                    }
                }
    
                citations.push({ text: part, filePath: path });
                citationIndex = citations.length;
            }

            return renderToStaticMarkup(
                <a className="supContainer" title={part} onClick={() => onCitationClicked(path)}>
                    <sup>{citationIndex}</sup>
                </a>
            );
        }
    });

    return {
        answerHtml: fragments.join(""),
        citations
    };
}
