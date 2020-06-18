import { SettingsCascade } from '../settings/settings'
import { SettingsEdit } from './client/services/settings'
import * as clientType from '@sourcegraph/extension-api-types'
import { Remote, ProxyMarked } from 'comlink'
import { Unsubscribable } from 'sourcegraph'
import { ProxySubscribable } from './extension/api/common'
import { TextDocumentPositionParams } from './protocol'
import { MaybeLoadingResult } from '@sourcegraph/codeintellify'
import { HoverMerged } from './client/types/hover'

/**
 * This is exposed from the extension host thread to the main thread
 * e.g. for communicating  direction "main -> ext host"
 * Note this API object lives in the extension host thread
 */
export interface FlatExtHostAPI {
    /**
     * Updates the settings exposed to extensions.
     */
    syncSettingsData: (data: Readonly<SettingsCascade<object>>) => void

    // Workspace
    syncRoots: (roots: readonly clientType.WorkspaceRoot[]) => void
    syncVersionContext: (versionContext: string | undefined) => void

    // Search
    transformSearchQuery: (query: string) => ProxySubscribable<string>

    getHover: (parameters: TextDocumentPositionParams) => ProxySubscribable<MaybeLoadingResult<HoverMerged | null>>
}

/**
 * This is exposed from the main thread to the extension host thread"
 * e.g. for communicating  direction "ext host -> main"
 * Note this API object lives in the main thread
 */
export interface MainThreadAPI {
    /**
     * Applies a settings update from extensions.
     */
    applySettingsEdit: (edit: SettingsEdit) => Promise<void>

    // Commands
    executeCommand: (command: string, args: any[]) => Promise<any>
    registerCommand: (
        name: string,
        command: Remote<((...args: any) => any) & ProxyMarked>
    ) => Unsubscribable & ProxyMarked
}
